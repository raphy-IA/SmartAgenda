class UserProfile {
  final String userId;
  final String chronotype; // matin, soir, neutre
  final bool freezeMode;
  final int workCapacityLimit;

  UserProfile({
    required this.userId,
    required this.chronotype,
    required this.freezeMode,
    required this.workCapacityLimit,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      chronotype: json['chronotype'] as String? ?? 'neutre',
      freezeMode: json['freeze_mode'] as bool? ?? false,
      workCapacityLimit: json['work_capacity_limit'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'chronotype': chronotype,
      'freeze_mode': freezeMode,
      'work_capacity_limit': workCapacityLimit,
    };
  }

  UserProfile copyWith({
    String? chronotype,
    bool? freezeMode,
    int? workCapacityLimit,
  }) {
    return UserProfile(
      userId: userId,
      chronotype: chronotype ?? this.chronotype,
      freezeMode: freezeMode ?? this.freezeMode,
      workCapacityLimit: workCapacityLimit ?? this.workCapacityLimit,
    );
  }
}
