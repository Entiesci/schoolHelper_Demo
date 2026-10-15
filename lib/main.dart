import 'package:flutter/material.dart';
import 'app_state.dart';          // 👈 Provider 现在这里
import 'home_shell.dart';
import 'pages/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: AppState(),
      child: MaterialApp(
        title: '回音信箱 - 校园反馈系统',
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
