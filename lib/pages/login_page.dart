import 'package:flutter/material.dart';
import '../../../app_state.dart';
import '../../../models.dart';
import '../../../mock_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedAccount = 'student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.school, size: 64, color: Color(0xFF3D5AFE)),
                    const SizedBox(height: 12),
                    Text('校园反馈系统',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 28),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '学号/工号', prefixIcon: Icon(Icons.person)),
                      initialValue: '2024001',
                      validator: (v) => (v == null || v.isEmpty) ? '请输入账号' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '密码', prefixIcon: Icon(Icons.lock)),
                      initialValue: '123456',
                      validator: (v) => (v == null || v.length < 6) ? '密码至少6位' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('演示账号（免密登录）：', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: accounts.entries.map((e) {
                        return ChoiceChip(
                          label: Text(e.value.role == Role.student ? e.value.name : e.value.dept!.label),
                          selected: selectedAccount == e.key,
                          onSelected: (_) => setState(() => selectedAccount = e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && selectedAccount != null) {
                          AppState.of(context).login(accounts[selectedAccount!]!);
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: const Text('登 录', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
