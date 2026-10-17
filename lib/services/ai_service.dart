import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = String.fromEnvironment(
    'DEEPSEEK_KEY',
    defaultValue: 'sk-aOcpypCUVIoH9bLtyPDKWjnpD3EjMoKxjb7gq3xGv7Y0Hcp4',
  );
  static const String _apiUrl = 'https://api.aicernet.cn/v1/chat/completions';

  /// 接口文档规定的 22 个标准类别
  static const List<String> categories = [
    '教学教务', '选课考试', '成绩学籍', '宿舍住宿', '后勤维修', '食堂餐饮',
    '校园网络', '图书馆服务', '校园交通', '校园安全', '医疗健康', '心理咨询',
    '社团活动', '评奖评优', '助学资助', '就业指导', '收费财务', '行政服务',
    '师德师风', '同学关系', '学术诚信', '其他',
  ];

  /// AI 自动分类，返回 {'cate': String, 'level': int}；失败返回 {'success': false, 'error': ...}
  static Future<Map<String, dynamic>> classify(String rawText) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'minimax-m3',
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是校园反馈系统的智能分类助手。分析学生反馈，判断问题类别和紧急程度。\n'
                  '类别只能从以下列表选择：${categories.join('、')}\n'
                  'level 为紧急程度：1=紧急（影响安全健康或大量学生）、2=一般、3=不紧急。\n'
                  '只输出 JSON，不要输出任何其他内容：\n'
                  '{"cate": "类别", "level": 2}',
            },
            {'role': 'user', 'content': rawText},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.1,
        }),
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'error': 'AI 服务返回 ${response.statusCode}',
        };
      }

      final content = jsonDecode(
          response.body)['choices'][0]['message']['content'] as String;
      final result = jsonDecode(content) as Map<String, dynamic>;

      final cate = (result['cate'] ?? '其他').toString();
      final level = result['level'] is int
          ? result['level'] as int
          : int.tryParse(result['level'].toString()) ?? 2;

      return {
        'success': true,
        'cate': categories.contains(cate) ? cate : '其他',   // 兜底
        'level': level.clamp(1, 3),
      };
    } catch (e) {
      return {'success': false, 'error': 'AI 分类失败：$e'};
    }
  }
}
