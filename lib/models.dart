import 'package:flutter/material.dart'; 
enum IssueStatus { pending, processing, resolved, closed }

enum IssuePriority {
  low('低', Colors.green),
  medium('中', Colors.orange),
  high('高', Colors.deepOrange),
  urgent('紧急', Colors.red);

  final String label;
  final Color color;
  const IssuePriority(this.label, this.color);
}
enum Dept {
  logistics('后勤部', Icons.cleaning_services),
  academic('教务处', Icons.school),
  dormitory('宿管科', Icons.bed),
  network('网络中心', Icons.wifi),
  security('保卫处', Icons.local_police);

  final String label;
  final IconData icon;
  const Dept(this.label, this.icon);
}

enum Role { student, staff }

class AppUser {
  final String name;
  final String studentId;
  final Role role;
  final Dept? dept;
  const AppUser(this.name, this.studentId, this.role, {this.dept});
}

class Issue {
  final String id;
  final String title;
  final String description;
  final String location;
  final Dept dept;
  final IssuePriority priority;
  IssueStatus status;
  final String submitter;
  final DateTime createdAt;
  final List<String> tags;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dept,
    required this.priority,
    required this.status,
    required this.submitter,
    required this.createdAt,
    this.tags = const [],
  });
}


/// AI 清洗结果
class AiCleaningResult {
  final String id;
  final String rawText;          // 原始脏数据
  final String rawSource;        // 来源：电话记录 / 微信群 / 问卷 / 邮件
  final DateTime rawTime;
  final String cleanTitle;       // 整理后标题
  Dept cleanDept;          // 识别部门
  IssuePriority cleanPriority; // 识别优先级
  final String cleanLocation;    // 提取地点
  final String cleanSummary;     // 结构化摘要
  final List<String> cleanTags;  // 提取标签
  final double confidence;       // AI 置信度 0~1
  bool adopted;                  // 是否已采纳入库

  AiCleaningResult({
    required this.id,
    required this.rawText,
    required this.rawSource,
    required this.rawTime,
    required this.cleanTitle,
    required this.cleanDept,
    required this.cleanPriority,
    required this.cleanLocation,
    required this.cleanSummary,
    required this.cleanTags,
    required this.confidence,
    this.adopted = false,
  });
}
