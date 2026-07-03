class Curriculum {
  final String id;
  final String title;
  final String description;
  final String level;

  Curriculum({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
    );
  }
}
