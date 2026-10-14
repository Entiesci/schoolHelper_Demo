import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models.dart';
import '../feedback_form_page.dart';
import '../issue_list_page.dart';
import '../kanban_page.dart';
import 'login_page.dart';
import '../todo_page.dart';
import 'ai_review_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final isStudent = state.isStudent;

    // 学生：列表 / 提交 / 看板；员工：待办 / 列表 / 看板
    final pages = isStudent
        ? [const IssueListPage(), const FeedbackFormPage(), const KanbanPage()]
        : [const TodoPage(), const AiReviewPage(), const IssueListPage(), const KanbanPage()];
        // : [const TodoPage(), const AiReviewPage(), const AiReviewPage(), const KanbanPage()];

    final navItems = isStudent
        ? const [BottomNavigationBarItem(icon: Icon(Icons.list), label: '问题列表'),
                 BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '提交反馈'),
                //  BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI 清洗'),
                 BottomNavigationBarItem(icon: Icon(Icons.view_kanban), label: '看板')]
        : const [
                BottomNavigationBarItem(icon: Icon(Icons.checklist), label: '我的待办'),
                BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI 清洗'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: '问题列表'),
                BottomNavigationBarItem(icon: Icon(Icons.view_kanban), label: '看板'),
              ];
    return Scaffold(
      appBar: AppBar(
        title: Text(navItems[index].label!),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              tooltip: '账户',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_circle, size: 32),
                  const SizedBox(width: 6),
                  Text(state.currentUser?.name ?? ''),
                ],
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'logout', child: Text('退出登录')),
              ],
              onSelected: (v) {
                if (v == 'logout') {
                  state.logout();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginPage()));
                }
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: navItems
            .map((e) => NavigationDestination(icon: e.icon, label: e.label!))
            .toList(),
      ),
    );
  }
}
