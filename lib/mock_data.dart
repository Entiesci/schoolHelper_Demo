import 'models.dart';

final mockIssues = [
  Issue(
    id: 'FB-1001', title: '三食堂二楼油烟味很重',
    description: '中午就餐时油烟味大，通风不佳', location: '三食堂',
    dept: Dept.logistics, priority: IssuePriority.high,
    status: IssueStatus.processing, submitter: '张三',
    createdAt: DateTime(2026, 10, 10), tags: ['食堂', '卫生'],
  ),
  Issue(
    id: 'FB-1002', title: '6号宿舍楼热水供应不稳定',
    description: '晚上10点后经常没有热水', location: '6号宿舍楼',
    dept: Dept.dormitory, priority: IssuePriority.urgent,
    status: IssueStatus.pending, submitter: '李四',
    createdAt: DateTime(2026, 10, 11), tags: ['宿舍', '热水'],
  ),
  Issue(
    id: 'FB-1003', title: '教学楼A101投影仪故障',
    description: '投影画面闪烁，影响上课', location: 'A栋101',
    dept: Dept.academic, priority: IssuePriority.medium,
    status: IssueStatus.resolved, submitter: '王五',
    createdAt: DateTime(2026, 10, 8), tags: ['教学设备'],
  ),
  Issue(
    id: 'FB-1004', title: '图书馆WiFi信号弱',
    description: '三楼自习区基本连不上WiFi', location: '图书馆3F',
    dept: Dept.network, priority: IssuePriority.high,
    status: IssueStatus.processing, submitter: '赵六',
    createdAt: DateTime(2026, 10, 12), tags: ['网络'],
  ),
  Issue(
    id: 'FB-1005', title: '东门路灯损坏',
    description: '东门往操场方向有两盏路灯不亮，晚上很黑', location: '东门',
    dept: Dept.security, priority: IssuePriority.medium,
    status: IssueStatus.pending, submitter: '张三',
    createdAt: DateTime(2026, 10, 12), tags: ['照明', '安全'],
  ),
  Issue(
    id: 'FB-1006', title: '篮球场地面破损',
    description: '2号半场地面裂缝，容易崴脚', location: '篮球场',
    dept: Dept.logistics, priority: IssuePriority.low,
    status: IssueStatus.closed, submitter: '李四',
    createdAt: DateTime(2026, 10, 5), tags: ['体育设施'],
  ),
];

final accounts = {
  'student': const AppUser('张同学', '2024001', Role.student),
  'logistics': const AppUser('后勤部 staff', 'S001', Role.staff, dept: Dept.logistics),
  'dormitory': const AppUser('宿管科 staff', 'S002', Role.staff, dept: Dept.dormitory),
  'academic': const AppUser('教务处 staff', 'S003', Role.staff, dept: Dept.academic),
  'network': const AppUser('网络中心 staff', 'S004', Role.staff, dept: Dept.network),
  'security': const AppUser('保卫处 staff', 'S005', Role.staff, dept: Dept.security),
};
