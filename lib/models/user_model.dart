class User {
  final String username;
  final String skillLevel;
  final int practiceSessions;
  final int totalPracticeTime;
  final List<String> ragasPracticed;
  final Map<String, double> personalizationData;
  final int practiceStreak;
  final List<String> achievements;
  final List<String> preferredRagas;

  User({
    required this.username,
    required this.skillLevel,
    required this.practiceSessions,
    required this.totalPracticeTime,
    required this.ragasPracticed,
    required this.personalizationData,
    required this.practiceStreak,
    required this.achievements,
    required this.preferredRagas,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      skillLevel: json['skill_level'],
      practiceSessions: json['practice_sessions'],
      totalPracticeTime: json['total_practice_time'],
      ragasPracticed: List<String>.from(json['ragas_practiced']),
      personalizationData: Map<String, double>.from(json['personalization_data']),
      practiceStreak: json['practice_streak'],
      achievements: List<String>.from(json['achievements']),
      preferredRagas: List<String>.from(json['preferred_ragas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'skill_level': skillLevel,
      'practice_sessions': practiceSessions,
      'total_practice_time': totalPracticeTime,
      'ragas_practiced': ragasPracticed,
      'personalization_data': personalizationData,
      'practice_streak': practiceStreak,
      'achievements': achievements,
      'preferred_ragas': preferredRagas,
    };
  }
}