class SkillMetrics {
  final double pitchAccuracy;
  final double rhythmStability;
  final double gamakaProfileiciency;
  final double breathControl;

  SkillMetrics({
    required this.pitchAccuracy,
    required this.rhythmStability,
    required this.gamakaProfileiciency,
    required this.breathControl,
  });

  factory SkillMetrics.fromJson(Map<String, dynamic> json) {
    return SkillMetrics(
      pitchAccuracy: (json['pitch_accuracy'] ?? 0.0).toDouble(),
      rhythmStability: (json['rhythm_stability'] ?? 0.0).toDouble(),
      gamakaProfileiciency: (json['gamaka_proficiency'] ?? 0.0).toDouble(),
      breathControl: (json['breath_control'] ?? 0.0).toDouble(),
    );
  }
}

class Improvement {
  final double overallScore;
  final int daysPracticing;

  Improvement({
    required this.overallScore,
    required this.daysPracticing,
  });

  factory Improvement.fromJson(Map<String, dynamic> json) {
    return Improvement(
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
      daysPracticing: json['days_practicing'] ?? 0,
    );
  }
}

class ProgressMetrics {
  final int sessionsCompleted;
  final int totalPracticeTime;
  final int currentStreak;
  final int ragasLearned;
  final SkillMetrics skillMetrics;
  final String skillLevel;
  final List<String> achievements;
  final Improvement? improvement;

  ProgressMetrics({
    required this.sessionsCompleted,
    required this.totalPracticeTime,
    required this.currentStreak,
    required this.ragasLearned,
    required this.skillMetrics,
    required this.skillLevel,
    required this.achievements,
    this.improvement,
  });

  factory ProgressMetrics.fromJson(Map<String, dynamic> json) {
    return ProgressMetrics(
      sessionsCompleted: json['sessions_completed'] ?? 0,
      totalPracticeTime: json['total_practice_time'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      ragasLearned: json['ragas_learned'] ?? 0,
      skillMetrics: SkillMetrics.fromJson(json['skill_metrics'] ?? {}),
      skillLevel: json['skill_level'] ?? 'beginner',
      achievements: List<String>.from(json['achievements'] ?? []),
      improvement: json.containsKey('improvement')
          ? Improvement.fromJson(json['improvement'])
          : null,
    );
  }
}

class PerformanceHistoryEntry {
  final String timestamp;
  final String raga;
  final double overallScore;
  final double aarohAdherence;
  final double avrohAdherence;
  final double pakadAdherence;
  final double rhythmStability;

  PerformanceHistoryEntry({
    required this.timestamp,
    required this.raga,
    required this.overallScore,
    required this.aarohAdherence,
    required this.avrohAdherence,
    required this.pakadAdherence,
    required this.rhythmStability,
  });

  DateTime get date => DateTime.parse(timestamp);

  factory PerformanceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PerformanceHistoryEntry(
      timestamp: json['timestamp'] ?? '',
      raga: json['raga'] ?? '',
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
      aarohAdherence: (json['aaroh_adherence'] ?? 0.0).toDouble(),
      avrohAdherence: (json['avroh_adherence'] ?? 0.0).toDouble(),
      pakadAdherence: (json['pakad_adherence'] ?? 0.0).toDouble(),
      rhythmStability: (json['rhythm_stability'] ?? 0.0).toDouble(),
    );
  }
}

class ProgressResponse {
  final ProgressMetrics metrics;
  final List<PerformanceHistoryEntry> history;

  ProgressResponse({
    required this.metrics,
    required this.history,
  });

  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    final historyJson = json['history'] as List<dynamic>? ?? [];
    final history = historyJson
        .map((entry) => PerformanceHistoryEntry.fromJson(entry))
        .toList();

    return ProgressResponse(
      metrics: ProgressMetrics.fromJson(json['metrics'] ?? {}),
      history: history,
    );
  }
}