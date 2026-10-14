import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models.dart';

extension PriorityX on IssuePriority {
  String get label => ['低', '中', '高', '紧急'][index];
  Color get color => [Colors.green, Colors.blue, Colors.orange, Colors.red][index];
}

extension StatusX on IssueStatus {
  String get label => ['待处理', '处理中', '已解决', '已关闭'][index];
  Color get color => [Colors.grey, Colors.blue, Colors.green, Colors.deepPurple][index];
}

enum SortField { createdAt, priority, dept, status }

class IssueListPage extends StatefulWidget {
  const IssueListPage({super.key});

  @override
  State<IssueListPage> createState() => _IssueListPageState();
}

class _IssueListPageState extends State<IssueListPage> {
  String _search = '';
  Dept? _filterDept;
  IssueStatus? _filterStatus;
  SortField _sortField = SortField.createdAt;
  bool _ascending = false;

  List<Issue> get _filtered {
    final state = AppState.of(context);
    var list = state.issues.where((e) {
      if (_search.isNotEmpty &&
          !e.title.contains(_search) &&
          !e.description.contains(_search) &&
          !e.location.contains(_search)) return false;
      if (_filterDept != null && e.dept != _filterDept) return false;
      if (_filterStatus != null && e.status != _filterStatus) return false;
      return true;
    }).toList();

    int cmp(Issue a, Issue b) => switch (_sortField) {
          SortField.createdAt => a.createdAt.compareTo(b.createdAt),
          SortField.priority => a.priority.index.compareTo(b.priority.index),
          SortField.dept => a.dept.index.compareTo(b.dept.index),
          SortField.status => a.status.index.compareTo(b.status.index),
        };
    list.sort((a, b) => _ascending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索标题 / 描述 / 地点...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty ? null : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _search = ''),
              ),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        // ===== 筛选 + 排序控制条 =====
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              DropdownButton<Dept?>(
                value: _filterDept,
                hint: const Text('部门'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部部门')),
                  ...Dept.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))),
                ],
                onChanged: (v) => setState(() => _filterDept = v),
              ),
              const SizedBox(width: 8),
              DropdownButton<IssueStatus?>(
                value: _filterStatus,
                hint: const Text('状态'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部状态')),
                  ...IssueStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                ],
                onChanged: (v) => setState(() => _filterStatus = v),
              ),
              const VerticalDivider(),
              const SizedBox(width: 8),
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 4),
              DropdownButton<SortField>(
                value: _sortField,
                items: const [
                  DropdownMenuItem(value: SortField.createdAt, child: Text('按时间')),
                  DropdownMenuItem(value: SortField.priority, child: Text('按优先级')),
                  DropdownMenuItem(value: SortField.dept, child: Text('按部门')),
                  DropdownMenuItem(value: SortField.status, child: Text('按状态')),
                ],
                onChanged: (v) => setState(() => _sortField = v!),
              ),
              IconButton(
                tooltip: _ascending ? '升序' : '降序',
                icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () => setState(() => _ascending = !_ascending),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('暂无匹配的问题'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final issue = _filtered[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(issue.dept.icon, size: 20),
                        ),
                        title: Text(issue.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${issue.id} · ${issue.dept.label} · ${issue.location} · ${issue.createdAt.month}/${issue.createdAt.day}'),
                        isThreeLine: true,
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(issue.priority.label, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: issue.priority.color.withOpacity(0.15),
                            ),
                            const SizedBox(height: 2),
                            Text(issue.status.label,
                                style: TextStyle(fontSize: 11, color: issue.status.color)),
                          ],
                        ),
                        onTap: () => _showDetail(context, issue),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, Issue issue) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(issue.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('编号：${issue.id} ｜ 提交人：${issue.submitter}\n'
                '部门：${issue.dept.label} ｜ 地点：${issue.location}\n'
                '优先级：${issue.priority.label} ｜ 状态：${issue.status.label}'),
            const SizedBox(height: 12),
            Text(issue.description),
            if (issue.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 6, children: issue.tags.map((t) => Chip(label: Text(t))).toList()),
            ],
            const SizedBox(height: 16),
            if (issue.status == IssueStatus.pending || issue.status == IssueStatus.processing)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  child: Text(issue.status == IssueStatus.pending ? '开始处理' : '标记为已解决'),
                  onPressed: () {
                    AppState.of(context).updateStatus(
                        issue.id,
                        issue.status == IssueStatus.pending
                            ? IssueStatus.processing
                            : IssueStatus.resolved);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
