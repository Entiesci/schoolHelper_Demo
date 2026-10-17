import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models.dart';
import '../../services/api_service.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  Dept _dept = Dept.logistics;
  IssuePriority _priority = IssuePriority.medium;
  final Set<String> _tags = {};
  bool _isSubmitting = false;
  String? _submitError;

  static const tagOptions = ['食堂', '宿舍', '教学', '网络', '安全', '卫生', '设备'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('提交问题反馈', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: '问题标题 *', hintText: '简要描述问题'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '请填写标题' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: '问题地点 *', hintText: '如：三食堂二楼'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '请填写地点' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '详细描述', alignLabelWithHint: true),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Dept>(
                  value: _dept,
                  decoration: const InputDecoration(labelText: '负责部门'),
                  items: Dept.values
                      .map((d) => DropdownMenuItem(value: d, child: Row(children: [
                            Icon(d.icon, size: 18), const SizedBox(width: 8), Text(d.label)])))
                      .toList(),
                  onChanged: (v) => setState(() => _dept = v!),
                ),
                const SizedBox(height: 20),
                const Text('紧急程度'),
                SegmentedButton<IssuePriority>(
                  segments: const [
                    ButtonSegment(value: IssuePriority.low, label: Text('低'), icon: Icon(Icons.low_priority)),
                    ButtonSegment(value: IssuePriority.medium, label: Text('中')),
                    ButtonSegment(value: IssuePriority.high, label: Text('高')),
                    ButtonSegment(value: IssuePriority.urgent, label: Text('紧急')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) => setState(() => _priority = s.first),
                ),
                const SizedBox(height: 20),
                const Text('标签'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: tagOptions.map((t) {
                    return FilterChip(
                      label: Text(t),
                      selected: _tags.contains(t),
                      onSelected: (v) => setState(() => v ? _tags.add(t) : _tags.remove(t)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                if (_submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _submitError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text(_isSubmitting ? '提交中...' : '提交反馈'),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            final title = _title.text.trim();
                            final description = _desc.text.trim();
                            final problem = [title, description].where((e) => e.isNotEmpty).join('\n');
                            final level = switch (_priority) {
                              IssuePriority.low => 1,
                              IssuePriority.medium => 2,
                              IssuePriority.high => 3,
                              IssuePriority.urgent => 4,
                            };

                            setState(() {
                              _isSubmitting = true;
                              _submitError = null;
                            });

                            try {
                              final response = await ApiService.submitFeedback(
                                problem: problem,
                                cate: _dept.label,
                                level: level,
                              );

                              if (response['success'] != true) {
                                throw Exception(response['error']?.toString() ?? '提交失败');
                              }

                              final id = 'FB-${1000 + AppState.of(context).issues.length + 1}';
                              AppState.of(context).addIssue(Issue(
                                id: id,
                                title: title,
                                description: description,
                                location: _location.text.trim(),
                                dept: _dept,
                                priority: _priority,
                                status: IssueStatus.pending,
                                submitter: AppState.of(context).currentUser!.name,
                                createdAt: DateTime.now(),
                                tags: _tags.toList(),
                              ));

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ 提交成功！编号 $id'), backgroundColor: Colors.green),
                              );
                              _formKey.currentState!.reset();
                              _title.clear(); _desc.clear(); _location.clear();
                              setState(() => _tags.clear());
                            } catch (e) {
                              if (!context.mounted) return;
                              setState(() {
                                _submitError = '提交失败：${e.toString()}';
                              });
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
