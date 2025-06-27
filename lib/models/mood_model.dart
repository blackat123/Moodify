class Mood {
  final int id;
  final String userId;
  final String mood;
  final String note;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.userId,
    required this.mood,
    required this.note,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      userId: json['user_id'],
      mood: json['mood'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
