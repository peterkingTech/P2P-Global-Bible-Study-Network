/// A study group created or joined by a peer.
class GroupModel {
  final String id;
  final String name;
  final String code;
  final String adminId;
  final DateTime createdAt;
  final int memberCount;

  const GroupModel({
    required this.id,
    required this.name,
    required this.code,
    required this.adminId,
    required this.createdAt,
    this.memberCount = 0,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        adminId: json['admin_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        memberCount: (json['member_count'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'admin_id': adminId,
        'created_at': createdAt.toIso8601String(),
        'member_count': memberCount,
      };

  GroupModel copyWith({
    String? id,
    String? name,
    String? code,
    String? adminId,
    DateTime? createdAt,
    int? memberCount,
  }) =>
      GroupModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        adminId: adminId ?? this.adminId,
        createdAt: createdAt ?? this.createdAt,
        memberCount: memberCount ?? this.memberCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GroupModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
