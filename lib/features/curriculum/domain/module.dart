class Module {
  final String id;
  final String curriculumId;
  final String title;
  final String description;
  final int orderIndex;

  Module({
    required this.id,
    required this.curriculumId,
    required this.title,
    required this.description,
    required this.orderIndex,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      curriculumId: json['curriculum_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      orderIndex: json['order_index'] as int,
    );
  }
}
