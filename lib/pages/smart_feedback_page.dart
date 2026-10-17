import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/ai_service.dart';
import '../services/local_feedback_store.dart'; 

class SmartFeedbackPage extends StatefulWidget {
  const SmartFeedbackPage({super.key});

  @override
  State<SmartFeedbackPage> createState() => _SmartFeedbackPageState();
}

class _SmartFeedbackPageState extends State<SmartFeedbackPage> {
  final _ctrl = TextEditingController();
  final _queryCtrl = TextEditingController();

  bool _aiLoading = false;
  bool _submitting = false;
  String? _error;

  String? _aiCate;   // AI 分类结果（可修正）
  int? _aiLevel;

  String? _tsKey;    // 提交成功后的回执

  // 查询结果
  Map<String, dynamic>? _queryResult;
  bool _querying = false;

  static const _levelLabels = {1: '紧急', 2: '一般', 3: '不紧急'};
  static const _levelColors = {
    1: Colors.red, 2: Colors.orange, 3: Colors.green,
  };

  // ─────────────────── 提交流程 ───────────────────

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = '请先描述你遇到的问题');
      return;
    }

    setState(() { _aiLoading = true; _error = null; _tsKey = null; });

    // 1️⃣ DeepSeek 自动分类
    final aiRes = await AiService.classify(text);
    if (aiRes['success'] != true) {
      setState(() {
        _error = aiRes['error'].toString();
        _aiLoading = false;
      });
      return;
    }
    setState(() {
      _aiCate = aiRes['cate'] as String;
      _aiLevel = aiRes['level'] as int;
      _aiLoading = false;
    });

    if (!mounted) return;

    // 2️⃣ 确认弹窗（学生可修正分类）
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(),
    );
    if (confirmed != true || !mounted) return;

    // 3️⃣ 提交到后端
    setState(() => _submitting = true);
    final res = await ApiService.submitFeedback(
      problem: text,
      cate: _aiCate!,
      level: _aiLevel!,
    );
    setState(() => _submitting = false);

    if (res['success'] == true) {
      setState(() {
        _tsKey = res['ts_key'].toString();
        _ctrl.clear();
      });
      LocalFeedbackStore.add(
        tsKey: _tsKey!,
        problem: text,
        cate: _aiCate!,
        level: _aiLevel!,
      );
    } else {
      setState(() => _error = res['error']?.toString() ?? '提交失败');
    }
  }

  Widget _confirmDialog() => StatefulBuilder(
    builder: (context, setDialogState) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.auto_awesome, color: Color(0xFF3D5AFE), size: 20),
        SizedBox(width: 8),
        Text('AI 已完成分类', style: TextStyle(fontSize: 18)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('可确认或手动修正后再提交：',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _aiCate,
            decoration: const InputDecoration(
                labelText: '问题类别', prefixIcon: Icon(Icons.category)),
            items: AiService.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setDialogState(() => _aiCate = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _aiLevel,
            decoration: const InputDecoration(
                labelText: '紧急程度', prefixIcon: Icon(Icons.priority_high)),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 - 紧急')),
              DropdownMenuItem(value: 2, child: Text('2 - 一般')),
              DropdownMenuItem(value: 3, child: Text('3 - 不紧急')),
            ],
            onChanged: (v) => setDialogState(() => _aiLevel = v),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认提交')),
      ],
    ),
  );

  // ─────────────────── 进度查询 ───────────────────

  Future<void> _query() async {
    final key = _queryCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() { _querying = true; _queryResult = null; });

    final res = await ApiService.getJson('/student/feedback/$key');
    setState(() {
      _querying = false;
      _queryResult = res['success'] == true
          ? res['data'] as Map<String, dynamic>
          : null;
      if (res['success'] != true) _error = '未查询到该编号的反馈';
    });
  }

  // ─────────────────── UI ───────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('智能反馈')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: '请描述你遇到的问题',
                hintText: '例如：三食堂二楼麻辣烫吃出了异物，希望学校检查',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            FilledButton.icon(
              onPressed: (_aiLoading || _submitting) ? null : _submit,
              icon: (_aiLoading || _submitting)
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_aiLoading ? 'AI 分类中…'
                  : _submitting ? '提交中…' : '智能提交'),
            ),
            if (_tsKey != null) ...[
              const SizedBox(height: 12),
              _receiptCard(),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            _querySection(),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x1A3D5AFE),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(children: [
      Icon(Icons.tips_and_updates, color: Color(0xFF3D5AFE)),
      SizedBox(width: 8),
      Expanded(
        child: Text('只需描述问题，AI 会自动完成分类和紧急程度判断，无需手动选择',
            style: TextStyle(fontSize: 13)),
      ),
    ]),
  );

  Widget _receiptCard() => Card(
    color: const Color(0xFFE8F5E9),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('提交成功！', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        SelectableText('回执编号：$_tsKey',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        const SizedBox(height: 4),
        Text('分类：$_aiCate · ${_levelLabels[_aiLevel]}（可在下方查询进度）',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    ),
  );

  Widget _querySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('📋 查询反馈进度', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _queryCtrl,
            decoration: const InputDecoration(
                hintText: '输入回执编号', isDense: true),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _querying ? null : _query,
          icon: _querying
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
        ),
      ]),
      if (_queryResult != null) ...[
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('状态：${_queryResult!['status'] ?? '未知'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('分类：${_queryResult!['cate'] ?? '-'}'),
                Text('级别：${_queryResult!['level'] ?? '-'}'),
              ],
            ),
          ),
        ),
      ],
    ],
  );

  @override
  void dispose() {
    _ctrl.dispose();
    _queryCtrl.dispose();
    super.dispose();
  }
}
