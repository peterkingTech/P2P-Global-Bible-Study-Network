class LessonBlock {
  final String id;
  final String lessonId;
  final String type;
  final String content;
  final int orderIndex;

  LessonBlock({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.content,
    required this.orderIndex,
  });

  factory LessonBlock.fromJson(Map<String, dynamic> json) {
    return LessonBlock(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      orderIndex: json['order_index'] as int,
    );
  }
}
