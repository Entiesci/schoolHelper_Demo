// import 'package:flutter/material.dart';
// import 'app_state.dart';
// import 'pages/home_shell.dart';
// import 'pages/login_page.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppStateProvider(
//       state: AppState(),          // 👈 直接传实例
//       child: MaterialApp(
//         title: '校园反馈系统',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: true,
//           colorSchemeSeed: const Color(0xFF3D5AFE),
//           inputDecorationTheme: const InputDecorationTheme(
//             border: OutlineInputBorder(),
//             filled: true,
//           ),
//         ),
//         home: const LoginPage(),
//         routes: {'/home': (_) => const HomeShell()},
//       ),
//     );
//   }
// }

// class AppStateProvider extends InheritedNotifier<AppState> {
//   const AppStateProvider({
//     super.key,
//     required AppState state,
//     required super.child,
//   }) : super(notifier: state);

//   /// 任意页面通过 AppState.of(context) 拿到全局状态
//   static AppState of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
// }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return ChangeNotifierProvider(
// //       // create: (_) => AppState(),
// //       state: AppState(),   
// //       child: MaterialApp(
// //         title: '校园反馈系统',
// //         debugShowCheckedModeBanner: false,
// //         theme: ThemeData(
// //           useMaterial3: true,
// //           colorSchemeSeed: const Color(0xFF3D5AFE),
// //           inputDecorationTheme: const InputDecorationTheme(
// //             border: OutlineInputBorder(),
// //             filled: true,
// //           ),
// //         ),
// //         home: const LoginPage(),
// //         routes: {'/home': (_) => const HomeShell()},
// //       ),
// //     );
// //   }
// // }

// /// 简化版 InheritedNotifier 作为状态提供者
// class ChangeNotifierProvider extends InheritedNotifier<AppState> {
//   ChangeNotifierProvider({
//     super.key,
//     required AppState Function() create,
//     required super.child,
//   }) : super(notifier: create());

//   static AppState of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType<ChangeNotifierProvider>()!.notifier!;
// }



import 'package:flutter/material.dart';
import 'app_state.dart';          // 👈 Provider 现在这里
import 'pages/home_shell.dart';
import 'pages/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: AppState(),
      child: MaterialApp(
        title: '校园反馈系统',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3D5AFE),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        home: const LoginPage(),
        routes: {'/home': (_) => const HomeShell()},
      ),
    );
  }
}
