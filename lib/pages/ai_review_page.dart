import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../mock_data.dart';
// import 'issue_list_page.dart'; // 复用 priority/status 扩展

class AiReviewPage extends StatefulWidget {
  const AiReviewPage({super.key});

  @override
  State<AiReviewPage> createState() => _AiReviewPageState();
}

class _AiReviewPageState extends State<AiReviewPage> {
  double _minConfidence = 0;
  bool _hideAdopted = false;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final results = state.aiResults
        .where((r) => r.confidence >= _minConfidence)
        .where((r) => !_hideAdopted || !r.adopted)
        .toList();

    return Column(
      children: [
        // ===== 顶部统计 + 筛选条 =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              _statCard(context, '待审核', '${state.aiResults.where((r) => !r.adopted).length}',
                  Icons.pending_actions, Colors.orange),
              const SizedBox(width: 8),
              _statCard(context, '已采纳', '${state.aiResults.where((r) => r.adopted).length}',
                  Icons.check_circle, Colors.green),
              const SizedBox(width: 8),
              _statCard(context, '平均置信度',
                  '${((state.aiResults.map((r) => r.confidence).reduce((a, b) => a + b) /
                          state.aiResults.length) * 100).toStringAsFixed(0)}%',
                  Icons.psychology, Color(0xFF3D5AFE)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('置信度 ≥ ', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Slider(
                  value: _minConfidence,
                  divisions: 10,
                  label: '${(_minConfidence * 100).toStringAsFixed(0)}%',
                  onChanged: (v) => setState(() => _minConfidence = v),
                ),
              ),
              Checkbox(
                value: _hideAdopted,
                onChanged: (v) => setState(() => _hideAdopted = v!),
              ),
              const Text('隐藏已采纳', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('暂无待审核数据'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CompareCard(
                    result: results[i],
                    onAdopt: () => _adopt(state, results[i]),
                    onEdit: () => _showEditSheet(context, state, results[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ]),
      ),
    );
  }

  // ===== 一键采纳：把清洗结果直接转成 Issue 入库 =====
  void _adopt(AppState state, AiCleaningResult r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('采纳并入库'),
        content: Text('将「${r.cleanTitle}」转为正式工单，指派给 ${r.cleanDept.label}？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              state.addIssue(Issue(
                id: 'FB-${2000 + state.issues.length}',
                title: r.cleanTitle,
                description: '${r.cleanSummary}\n\n[AI清洗自 ${r.rawSource}]',
                location: r.cleanLocation,
                dept: r.cleanDept,
                priority: r.cleanPriority,
                status: IssueStatus.pending,
                submitter: 'AI清洗·${r.rawSource}',
                createdAt: DateTime.now(),
                tags: r.cleanTags,
              ));
              state.adoptAiResult(r.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ ${r.id} 已入库并派发至${r.cleanDept.label}'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('确认入库'),
          ),
        ],
      ),
    );
  }

  // ===== 人工修正：低置信度时人工调整后再入库 =====
  void _showEditSheet(BuildContext context, AppState state, AiCleaningResult r) {
    Dept dept = r.cleanDept;
    IssuePriority priority = r.cleanPriority;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('人工修正 · ${r.id}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<Dept>(
                value: dept,
                decoration: const InputDecoration(labelText: '部门'),
                items: Dept.values.map((d) =>
                    DropdownMenuItem(value: d, child: Text(d.label))).toList(),
                onChanged: (v) => setSheet(() => dept = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<IssuePriority>(
                value: priority,
                decoration: const InputDecoration(labelText: '优先级'),
                items: IssuePriority.values.map((p) =>
                    DropdownMenuItem(value: p, child: Text(p.label))).toList(),
                onChanged: (v) => setSheet(() => priority = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  child: const Text('保存修正并标记采纳'),
                  onPressed: () {
                    state.correctAiResult(r.id, dept, priority);
                    Navigator.pop(ctx);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== 单条对比卡片：左原始 / 右结构化 =====
class _CompareCard extends StatelessWidget {
  final AiCleaningResult result;
  final VoidCallback onAdopt;
  final VoidCallback onEdit;

  const _CompareCard({required this.result, required this.onAdopt, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: r.adopted
          ? ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(r.cleanTitle,
                  style: const TextStyle(decoration: TextDecoration.lineThrough)),
              subtitle: Text('已采纳入库 · 置信度 ${(r.confidence * 100).toStringAsFixed(0)}%'),
            )
          : Column(
              children: [
                // 头部：编号 + 来源 + 置信度
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.grey.shade100,
                  child: Row(children: [
                    Text(r.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(r.rawSource, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.purple.withOpacity(0.12),
                    ),
                    const Spacer(),
                    Icon(Icons.psychology, size: 14, color: _confColor(r.confidence)),
                    const SizedBox(width: 4),
                    Text('${(r.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: _confColor(r.confidence))),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(builder: (ctx, box) {
                    final isWide = box.maxWidth > 640;
                    final raw = _rawPanel(r);
                    final clean = _cleanPanel(r);
                    return isWide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: raw),
                            _arrow(),
                            Expanded(flex: 2, child: clean),
                          ])
                        : Column(children: [raw, _arrow(), clean]);
                  }),
                ),
                // 操作栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(children: [
                    const Spacer(),
                    TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('人工修正')),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                        onPressed: onAdopt,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('采纳入库')),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _arrow() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(Icons.arrow_forward, color: Color(0xFF3D5AFE)),
      );

  // 左：原始脏数据
  Widget _rawPanel(AiCleaningResult r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.record_voice_over, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text('原始数据 · ${r.rawSource}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: Colors.orange)),
        ]),
        const SizedBox(height: 8),
        Text(r.rawText,
            style: const TextStyle(fontSize: 13, height: 1.5,
                fontStyle: FontStyle.italic, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('🕐 ${r.rawTime.month}/${r.rawTime.day} ${r.rawTime.hour}:${r.rawTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }

  // 右：AI 整理后的结构化数据
  Widget _cleanPanel(AiCleaningResult r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_awesome, size: 14, color: Color(0xFF3D5AFE)),
          SizedBox(width: 4),
          Text('AI 整理结果',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: Color(0xFF3D5AFE))),
        ]),
        const SizedBox(height: 8),
        Text(r.cleanTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Text(r.cleanSummary, style: const TextStyle(fontSize: 12, height: 1.4)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 4, children: [
          _miniChip(Icons.business, r.cleanDept.label),
          _miniChip(Icons.flag, r.cleanPriority.label, color: r.cleanPriority.color),
          _miniChip(Icons.place, r.cleanLocation),
          ...r.cleanTags.map((t) => _miniChip(Icons.tag, t)),
        ]),
      ]),
    );
  }

  Widget _miniChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? Colors.blueGrey).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color ?? Colors.blueGrey),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: color ?? Colors.blueGrey)),
      ]),
    );
  }

  Color _confColor(double c) =>
      c >= 0.9 ? Colors.green : (c >= 0.75 ? Colors.orange : Colors.red);
}
