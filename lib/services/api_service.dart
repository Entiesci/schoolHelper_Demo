import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

class ApiService {
  static const String baseUrl = 'https://8.138.236.211.nip.io';

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final queryParams = <String, String>{
        ...uri.queryParameters,
        ...body.map((key, value) => MapEntry(key, value.toString())),
      };

      final response = await http.post(
        uri.replace(queryParameters: queryParams),
        headers: {'Content-Type': 'application/json', ...?headers},
        body: jsonEncode(body),
      );

      return _decodeResponse(response);
    } on http.ClientException catch (e) {
      return _networkError('POST', path, e);
    }
  }

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {'Accept': 'application/json', ...?headers},
      );

      return _decodeResponse(response);
    } on http.ClientException catch (e) {
      return _networkError('GET', path, e);
    }
  }

  static Map<String, dynamic> _networkError(
    String method,
    String path,
    http.ClientException error,
  ) {
    return {
      'success': false,
      'error': '网络请求失败：$method $path',
      'message': error.message,
      'uri': error.uri?.toString(),
      'hint': '通常是后端未配置 CORS、域名解析异常或 TLS/证书问题。请检查服务端 Access-Control-Allow-Origin 与 OPTIONS 预检。',
    };
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {'success': false, 'error': '响应不是 JSON 对象', 'raw': response.body};
    } catch (_) {
      return {'success': false, 'error': '响应解析失败', 'raw': response.body};
    }
  }

  static Future<Map<String, dynamic>> loginToken({required String identity}) {
    return postJson('/auth/token', {'identity': identity});
  }

  static Future<Map<String, dynamic>> verifyIdentity({required String token}) {
    return postJson('/auth/identity', {'token': token});
  }

  static Future<Map<String, dynamic>> submitFeedback({
    required String problem,
    required String cate,
    required int level,
  }) {
    return postJson('/student/feedback', {
      'problem': problem,
      'cate': cate,
      'level': level,
    });
  }

  static Future<Map<String, dynamic>> startCrawl({
    String circleId = '1210732206482463872',
  }) {
    return postJson('/crawl/run', {'circle_id': circleId});
  }

  static Future<Map<String, dynamic>> getCrawlStatus(String taskKey) {
    return getJson('/crawl/status/$taskKey');
  }

  static Future<Map<String, dynamic>> getCrawlRecords(String taskKey) {
    return getJson('/crawl/records/$taskKey');
  }

  static Future<Map<String, dynamic>> getCrawlResult(String taskKey) {
    return getJson('/crawl/result/$taskKey');
  }

  static List<AiCleaningResult> parseCrawlResult(Map<String, dynamic> payload) {
    final items = payload['issues'] as List? ?? const [];
    if (items.isEmpty) {
      return const [];
    }

    final allPosts = (payload['posts'] as List?) ?? const [];
    final allPostByUid = <String, String>{};
    for (final post in allPosts.whereType<Map>()) {
      final uid = (post['uid'] ?? '').toString();
      final text = (post['text'] ?? '').toString();
      if (uid.isNotEmpty && text.trim().isNotEmpty) {
        allPostByUid[uid] = text;
      }
    }

    final results = <AiCleaningResult>[];
    for (var i = 0; i < items.length; i++) {
      final issue = items[i] as Map<String, dynamic>;
      final issueText = (issue['issue'] ?? 'AI 识别结果').toString();
      final cate = (issue['cate'] ?? '未分类').toString();
      final level = issue['level'] is int ? issue['level'] as int : 2;

      final posts = (issue['posts'] as List?) ?? const [];
      final postTexts = <String>[];

      for (final post in posts.whereType<Map>()) {
        final text = (post['text'] ?? '').toString();
        if (text.trim().isNotEmpty) {
          postTexts.add(text);
        }
      }

      final relatedUids = (issue['uids'] as List?) ?? const [];
      if (postTexts.isEmpty && relatedUids.isNotEmpty) {
        for (final uid in relatedUids) {
          final text = allPostByUid[uid.toString()];
          if (text != null && text.trim().isNotEmpty) {
            postTexts.add(text);
          }
        }
      }

      final rawText = postTexts.isNotEmpty ? postTexts.join('\n---\n') : issueText;

      final reasoningList = (issue['reasonings'] as List?) ?? const [];
      final reasoningText = reasoningList.isNotEmpty
          ? reasoningList.map((e) => e.toString()).join('\n')
          : (issue['reasoning_detail'] is List)
              ? (issue['reasoning_detail'] as List)
                  .map(
                    (e) => e is Map ? (e['answer'] ?? '').toString() : e.toString(),
                  )
                  .join('\n')
              : '';

      results.add(
        AiCleaningResult(
          id: 'AI-${(i + 1).toString().padLeft(3, '0')}',
          rawText: rawText,
          rawSource: 'AI 合并原始帖子',
          rawTime: DateTime.now(),
          cleanTitle: issueText,
          cleanDept: _mapCategoryToDept(cate),
          cleanPriority: _mapLevelToPriority(level),
          cleanLocation: issueText.length > 20 ? issueText.substring(0, 20) : issueText,
          cleanSummary: reasoningText.isNotEmpty ? reasoningText : issueText,
          cleanTags: _extractTags(cate, issueText),
          confidence: 0.8 + (level / 10.0),
        ),
      );
    }

    return results;
  }

  static Dept _mapCategoryToDept(String category) {
    final value = category.toLowerCase();
    if (value.contains('宿舍') || value.contains('宿管') || value.contains('宿舍楼')) {
      return Dept.dormitory;
    }
    if (value.contains('教学') ||
        value.contains('教务') ||
        value.contains('课') ||
        value.contains('学校')) {
      return Dept.academic;
    }
    if (value.contains('网络') || value.contains('wifi') || value.contains('网')) {
      return Dept.network;
    }
    if (value.contains('保卫') ||
        value.contains('安全') ||
        value.contains('门') ||
        value.contains('路灯')) {
      return Dept.security;
    }
    if (value.contains('后勤') ||
        value.contains('食堂') ||
        value.contains('卫生') ||
        value.contains('设备')) {
      return Dept.logistics;
    }
    return Dept.logistics;
  }

  static IssuePriority _mapLevelToPriority(int level) {
    if (level >= 4) return IssuePriority.urgent;
    if (level == 3) return IssuePriority.high;
    if (level == 2) return IssuePriority.medium;
    return IssuePriority.low;
  }

  static List<String> _extractTags(String category, String issueText) {
    final items = <String>[];
    if (category.isNotEmpty && category != '未分类') items.add(category);
    final normalized = issueText.replaceAll(
      RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9]'),
      '',
    );
    if (normalized.length > 2) {
      items.add(
        normalized.substring(0, normalized.length > 8 ? 8 : normalized.length),
      );
    }
    return items;
  }
}
