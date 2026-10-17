import '../models.dart';

/// 本地暂存学生提交的反馈，供 AI 清洗页合并展示（演示用）
class LocalFeedbackStore {
  static final List<AiCleaningResult> _items = [];

  static void add({
    required String tsKey,
    required String problem,
    required String cate,
    required int level,
  }) {
    _items.insert(
      0,
      AiCleaningResult(
        id: tsKey,
        rawText: problem,
        rawSource: '学生主动反馈',
        rawTime: DateTime.now(),
        cleanTitle: problem.length > 15 ? problem.substring(0, 15) : problem,
        cleanDept: Dept.logistics, // 可复用 ApiService._mapCategoryToDept
        cleanPriority: level >= 2 ? IssuePriority.high : IssuePriority.medium,
        cleanLocation: '—',
        cleanSummary: '类别：$cate',
        cleanTags: [cate],
        confidence: 0.95,
      ),
    );
  }

  static List<AiCleaningResult> get items => List.unmodifiable(_items);
}
