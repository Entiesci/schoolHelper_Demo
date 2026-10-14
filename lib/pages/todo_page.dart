import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models.dart';
// import 'issue_list_page.dart'; // 复用扩展
// import '../../main.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context); 
    final myDept = state.currentUser!.dept!;
    if (state.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
  }
    final todos = state.issues
        .where((e) => e.dept == myDept &&
            (e.status == IssueStatus.pending || e.status == IssueStatus.processing))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(myDept.icon, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(myDept.label, style: Theme.of(context).textTheme.titleLarge),
                  Text('待办 ${todos.length} 项'),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (todos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('🎉 太棒了，暂无待办！')),
          )
        else
          ...todos.map((issue) => Card(
                child: ListTile(
                  leading: issue.status == IssueStatus.pending
                      ? const Icon(Icons.circle, color: Colors.red, size: 12)
                      : const Icon(Icons.autorenew, color: Colors.blue, size: 18),
                  title: Text(issue.title),
                  subtitle: Text('${issue.location} · ${issue.priority.label}优先级'),
                  trailing: issue.status == IssueStatus.pending
                      ? FilledButton.tonal(
                          onPressed: () => state.updateStatus(issue.id, IssueStatus.processing),
                          child: const Text('接单'))
                      : FilledButton(
                          onPressed: () => state.updateStatus(issue.id, IssueStatus.resolved),
                          child: const Text('完成')),
                ),
              )),
      ],
    );
  }
}
