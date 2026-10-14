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


// ... 已有的 mockIssues、accounts 保持不变 ...

final mockAiResults = [
  AiCleaningResult(
    id: 'AI-001',
    rawText: '刚打电话来说他们宿舍晚上洗漱高峰期水压特别低，楼上的人基本上没水用，'
        '说是好像五楼六楼最严重，都有人发火了，希望尽快处理一下',
    rawSource: '电话记录',
    rawTime: DateTime(2026, 10, 12, 21, 35),
    cleanTitle: '宿舍高层水压不足，晚间洗漱用水困难',
    cleanDept: Dept.dormitory,
    cleanPriority: IssuePriority.urgent,
    cleanLocation: '宿舍楼5-6层',
    cleanSummary: '晚间用水高峰期5、6楼水压过低，影响正常洗漱，学生情绪较为激动，需尽快排查供水系统',
    cleanTags: ['宿舍', '水压', '供水'],
    confidence: 0.94,
  ),
  AiCleaningResult(
    id: 'AI-002',
    rawText: '群里有人反馈说教学楼那个电梯按钮坏的 让修一下',
    rawSource: '微信群聊',
    rawTime: DateTime(2026, 10, 12, 14, 12),
    cleanTitle: '教学楼电梯按钮故障',
    cleanDept: Dept.logistics,
    cleanPriority: IssuePriority.medium,
    cleanLocation: '教学楼',
    cleanSummary: '教学楼电梯楼层按钮损坏，影响师生正常使用，需安排维修',
    cleanTags: ['教学设施', '电梯', '维修'],
    confidence: 0.88,
  ),
  AiCleaningResult(
    id: 'AI-003',
    rawText: '不知道该跟谁反映 我在图书馆四楼自习 旁边有人外放声音特别大 '
        '说了几次都不听 管理员也不管 感觉自习环境完全没保障',
    rawSource: '邮件',
    rawTime: DateTime(2026, 10, 11, 19, 48),
    cleanTitle: '图书馆自习区噪音管理缺失',
    cleanDept: Dept.academic,
    cleanPriority: IssuePriority.high,
    cleanLocation: '图书馆4F自习区',
    cleanSummary: '有读者在自习区外放音频，多次劝阻无效且未见管理员介入，自习秩序管理需加强',
    cleanTags: ['图书馆', '噪音', '管理'],
    confidence: 0.79,
  ),
  AiCleaningResult(
    id: 'AI-004',
    rawText: '问卷第3题填的其他：饭卡丢了在机器上挂失了但是食堂的人说没收到还是能用？？',
    rawSource: '问卷调查',
    rawTime: DateTime(2026, 10, 10, 12, 30),
    cleanTitle: '饭卡挂失系统与食堂终端不同步',
    cleanDept: Dept.logistics,
    cleanPriority: IssuePriority.urgent,
    cleanLocation: '食堂',
    cleanSummary: '学生挂失饭卡后食堂刷卡终端未同步失效，存在资金安全风险，疑似挂失系统数据同步故障',
    cleanTags: ['饭卡', '挂失', '系统故障'],
    confidence: 0.91,
  ),
  AiCleaningResult(
    id: 'AI-005',
    rawText: '操场那个照明灯闪烁闪了好久了 频率不是很高但是晚上看着挺难受的 会不会坏掉啊',
    rawSource: '电话记录',
    rawTime: DateTime(2026, 10, 9, 20, 15),
    cleanTitle: '操场照明灯异常闪烁，存在损坏风险',
    cleanDept: Dept.security,
    cleanPriority: IssuePriority.low,
    cleanLocation: '操场',
    cleanSummary: '操场照明灯长时间间歇性闪烁，尚可使用但有完全损坏风险，建议检修',
    cleanTags: ['照明', '操场', '检修'],
    confidence: 0.72,
  ),
];
