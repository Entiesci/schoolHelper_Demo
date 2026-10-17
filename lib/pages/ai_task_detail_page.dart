import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/api_service.dart';

class AiTaskDetailPage extends StatefulWidget {
  final String? taskKey;

  const AiTaskDetailPage({super.key, this.taskKey});

  @override
  State<AiTaskDetailPage> createState() => _AiTaskDetailPageState();
}

class _AiTaskDetailPageState extends State<AiTaskDetailPage> {
  String? _taskKey;
  String _status = '加载中';
  Map<String, dynamic>? _result;
  List<dynamic> _rawRecords = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
  }

  Future<void> _loadTask() async {
    final state = AppState.of(context);
    final key = widget.taskKey ?? state.latestAiTaskKey;

    if (key == null || key.trim().isEmpty) {
      setState(() {
        _error = '暂无可查看的 AI 任务 Key';
        _loading = false;
      });
      return;
    }

    setState(() {
      _taskKey = key;
      _status = '查询中';
    });

    await state.saveLatestAiTaskKey(key);

    try {
      final statusResp = await ApiService.getCrawlStatus(key);
      final status = statusResp['status']?.toString() ?? 'unknown';
      setState(() => _status = status);

      if (status != 'done') {
        setState(() => _loading = false);
        return;
      }

      final recordsResp = await ApiService.getCrawlRecords(key);
      final resultResp = await ApiService.getCrawlResult(key);
      if (resultResp['success'] != true) {
        throw Exception(resultResp['error']?.toString() ?? '查询任务结果失败');
      }

      setState(() {
        _result = resultResp;
        _rawRecords = recordsResp['success'] == true
            ? (recordsResp['data'] as List? ?? const [])
            : const [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_taskKey == null ? 'AI 任务详情' : 'AI 任务：$_taskKey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTask,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final issueList = (_result?['issues'] as List? ?? const []);
    final resultPosts = (_result?['posts'] as List? ?? const []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('任务信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoRow('Task Key', _taskKey ?? '-'),
                  _infoRow('状态', _status),
                  _infoRow('原始帖子', '${_rawRecords.length + resultPosts.length} 条'),
                  _infoRow('AI issue', '${issueList.length} 条'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '原始数据与 AI 对比',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (issueList.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('当前任务没有可展示的 issue。')))
          else
            ...List.generate(issueList.length, (index) {
              final issue = issueList[index] as Map<String, dynamic>;
              final issueText = (issue['issue'] ?? '未命名问题').toString();
              final category = (issue['cate'] ?? '未分类').toString();
              final level = issue['level'] is int ? issue['level'] as int : 0;
              final issuePosts = (issue['posts'] as List?) ?? const [];
              final reasoningList = (issue['reasonings'] as List?) ?? const [];
              final reasoningDetail = (issue['reasoning_detail'] as List?) ?? const [];

              final relatedUids = (issue['uids'] as List?) ?? const [];
              final rawTextFromIssue = _joinPostText(
                issuePosts.whereType<Map>().toList(),
                matchUids: const [],
              );

              final rawTextFromResult = _joinPostText(
                resultPosts.whereType<Map>().toList(),
                matchUids: relatedUids.map((e) => e.toString()).toList(),
              );

              final rawText = rawTextFromIssue.isNotEmpty
                  ? rawTextFromIssue
                  : rawTextFromResult.isNotEmpty
                      ? rawTextFromResult
                      : _joinPostText(
                          _rawRecords.whereType<Map>().toList(),
                          matchUids: relatedUids.map((e) => e.toString()).toList(),
                        );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issueText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(category), avatar: const Icon(Icons.category, size: 16)),
                          Chip(label: Text('级别 $level'), avatar: const Icon(Icons.flag, size: 16)),
                          Chip(label: Text('${_countRawPosts(issuePosts, relatedUids)} 条原始帖子'), avatar: const Icon(Icons.article, size: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('原始帖子', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          rawText.isEmpty ? '没有关联的原始帖子' : rawText,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('AI 整理后结果', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(issueText, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              reasoningList.isNotEmpty
                                  ? reasoningList.map((e) => e.toString()).join('\n\n')
                                  : reasoningDetail.isNotEmpty
                                      ? reasoningDetail
                                          .map((e) => e is Map ? (e['answer'] ?? '').toString() : e.toString())
                                          .join('\n\n')
                                      : '暂无深度推理记录',
                              style: const TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  int _countRawPosts(List<dynamic> issuePosts, List<dynamic> relatedUids) {
    final countFromIssue = issuePosts.whereType<Map>().where((post) {
      return _extractPostText(post).trim().isNotEmpty || (post['uid'] ?? '').toString().isNotEmpty;
    }).length;

    if (countFromIssue > 0) {
      return countFromIssue;
    }

    if (relatedUids.isEmpty) {
      return _rawRecords.length;
    }

    return _rawRecords.whereType<Map>().where((post) {
      final uid = (post['uid'] ?? '').toString();
      return relatedUids.contains(uid) || _extractPostText(post).trim().isNotEmpty;
    }).length;
  }

  String _joinPostText(List<Map<dynamic, dynamic>> posts, {required List<String> matchUids}) {
    final texts = <String>[];
    for (final post in posts) {
      final uid = (post['uid'] ?? '').toString();
      if (matchUids.isNotEmpty && uid.isNotEmpty && !matchUids.contains(uid)) {
        continue;
      }

      final text = _extractPostText(post);
      if (text.trim().isNotEmpty) {
        texts.add(text);
      }
    }

    if (texts.isNotEmpty) {
      return texts.join('\n---\n');
    }

    for (final post in posts) {
      final text = _formatDebugPost(post);
      if (text.trim().isNotEmpty) {
        texts.add(text);
      }
    }

    return texts.join('\n---\n');
  }

  String _extractPostText(Map<dynamic, dynamic> post) {
    final candidates = [
      post['text'],
      post['content'],
      post['message'],
      post['body'],
      post['detail'],
      post['summary'],
      post['rewrite'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
      if (candidate is Map) {
        final nested = candidate['text'] ?? candidate['content'] ?? candidate['message'];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
      }
    }

    return '';
  }

  String _formatDebugPost(Map<dynamic, dynamic> post) {
    final text = _extractPostText(post);
    if (text.trim().isNotEmpty) return text;

    final uid = (post['uid'] ?? 'unknown').toString();
    return 'uid=$uid\n${post.toString()}';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
