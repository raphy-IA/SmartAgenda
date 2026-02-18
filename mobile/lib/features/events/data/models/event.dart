class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String status;
  final String? categoryId;
  final Map<String, dynamic>? metadata;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.status,
    this.categoryId,
    this.metadata,
  });

  int get importanceScore => (metadata?['importance_score'] as int?) ?? 40;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      endTime: DateTime.parse(json['end_time'] as String).toLocal(),
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'confirmed',
      categoryId: json['category_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'location': location,
      'status': status,
      'category_id': categoryId,
      'metadata': metadata,
    };
  }
}
