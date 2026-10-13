import 'package:flutter/material.dart'; 
enum IssueStatus { pending, processing, resolved, closed }

enum IssuePriority { low, medium, high, urgent }

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
