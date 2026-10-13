// import 'package:flutter/material.dart';
// import 'models.dart';
// import 'mock_data.dart';

// class AppState extends ChangeNotifier {
//   AppUser? currentUser;
//   final List<Issue> issues = List.from(mockIssues);

//   bool get isStudent => currentUser?.role == Role.student;

//   void login(AppUser user) {
//     currentUser = user;
//     notifyListeners();
//   }

//   void logout() {
//     currentUser = null;
//     notifyListeners();
//   }

//   void addIssue(Issue issue) {
//     issues.insert(0, issue);
//     notifyListeners();
//   }

//   void updateStatus(String id, IssueStatus status) {
//     issues.firstWhere((e) => e.id == id).status = status;
//     notifyListeners();
//   }
// }



import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_data.dart';

class AppState extends ChangeNotifier {
  AppUser? currentUser;
  final List<Issue> issues = List.from(mockIssues);

  bool get isStudent => currentUser?.role == Role.student;

  // ⭐ 关键：直接在 AppState 上定义静态 of 方法
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;


  void login(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void addIssue(Issue issue) {
    issues.insert(0, issue);
    notifyListeners();
  }

  void updateStatus(String id, IssueStatus status) {
    issues.firstWhere((e) => e.id == id).status = status;
    notifyListeners();
  }
}

/// 👇 把 Provider 类从 main.dart 挪到这里
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// 任意页面通过 AppState.of(context) 拿到全局状态
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
}
