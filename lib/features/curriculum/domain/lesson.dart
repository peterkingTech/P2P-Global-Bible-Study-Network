class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String summary;
  final int orderIndex;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.orderIndex,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      orderIndex: json['order_index'] as int,
    );
  }
}
