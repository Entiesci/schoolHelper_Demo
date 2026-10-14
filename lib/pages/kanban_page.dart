import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models.dart';
import 'issue_list_page.dart'; // 复用扩展

class KanbanPage extends StatelessWidget {
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final issues = AppState.of(context).issues;
    final columns = {
      IssueStatus.pending: issues.where((e) => e.status == IssueStatus.pending).toList(),
      IssueStatus.processing: issues.where((e) => e.status == IssueStatus.processing).toList(),
      IssueStatus.resolved: issues.where((e) => e.status == IssueStatus.resolved).toList(),
      IssueStatus.closed: issues.where((e) => e.status == IssueStatus.closed).toList(),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: IssueStatus.values.map((status) {
        final cards = columns[status]!;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(status.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      CircleAvatar(radius: 10, backgroundColor: status.color,
                          child: Text('${cards.length}', style: const TextStyle(fontSize: 11, color: Colors.white))),
                    ],
                  ),
                ),
                Expanded(
                  child: cards.isEmpty
                      ? const Center(child: Text('空', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: cards.length,
                          itemBuilder: (_, i) => _KanbanCard(issue: cards[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Issue issue;
  const _KanbanCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(issue.dept.icon, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(issue.id, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: issue.priority.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(issue.priority.label,
                    style: TextStyle(fontSize: 10, color: issue.priority.color)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(issue.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text('📍 ${issue.location} · 👤 ${issue.submitter}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
