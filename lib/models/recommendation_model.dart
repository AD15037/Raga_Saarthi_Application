class RagaRecommendation {
  final String raga;
  final String reason;

  RagaRecommendation({
    required this.raga,
    required this.reason,
  });

  factory RagaRecommendation.fromJson(Map<String, dynamic> json) {
    return RagaRecommendation(
      raga: json['raga'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class PracticeExercise {
  final String name;
  final int duration;
  final String description;
  final String importance;

  PracticeExercise({
    required this.name,
    required this.duration,
    required this.description,
    required this.importance,
  });

  factory PracticeExercise.fromJson(Map<String, dynamic> json) {
    return PracticeExercise(
      name: json['name'] ?? '',
      duration: json['duration'] ?? 0,
      description: json['description'] ?? '',
      importance: json['importance'] ?? 'medium',
    );
  }
}

class PracticeRoutine {
  final int dailyPracticeTime;
  final List<PracticeExercise> exercises;
  final String? additionalAdvice;

  PracticeRoutine({
    required this.dailyPracticeTime,
    required this.exercises,
    this.additionalAdvice,
  });

  factory PracticeRoutine.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesJson
        .map((exerciseJson) => PracticeExercise.fromJson(exerciseJson))
        .toList();

    return PracticeRoutine(
      dailyPracticeTime: json['daily_practice_time'] ?? 0,
      exercises: exercises,
      additionalAdvice: json['additional_advice'],
    );
  }
}

class RecommendationsResponse {
  final List<RagaRecommendation> ragaRecommendations;
  final PracticeRoutine practiceRoutine;

  RecommendationsResponse({
    required this.ragaRecommendations,
    required this.practiceRoutine,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    final ragaRecsJson = json['raga_recommendations'] as List<dynamic>? ?? [];
    final ragaRecommendations = ragaRecsJson
        .map((recJson) => RagaRecommendation.fromJson(recJson))
        .toList();

    return RecommendationsResponse(
      ragaRecommendations: ragaRecommendations,
      practiceRoutine: PracticeRoutine.fromJson(json['practice_routine'] ?? {}),
    );
  }
}

class VideoRecommendation {
  final String title;
  final String url;
  final String description;
  final double? score;

  VideoRecommendation({
    required this.title,
    required this.url,
    required this.description,
    this.score,
  });

  factory VideoRecommendation.fromJson(Map<String, dynamic> json) {
    return VideoRecommendation(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      score: json['score']?.toDouble(),
    );
  }
}

class VideoRecommendations {
  final List<VideoRecommendation> skillImprovement;
  final List<VideoRecommendation> ragaExamples;
  final List<VideoRecommendation> techniqueTutorials;

  VideoRecommendations({
    required this.skillImprovement,
    required this.ragaExamples,
    required this.techniqueTutorials,
  });

  factory VideoRecommendations.fromJson(Map<String, dynamic> json) {
    final skillImprovement = (json['skill_improvement'] as List<dynamic>? ?? [])
        .map((item) => VideoRecommendation.fromJson(item))
        .toList();
        
    final ragaExamples = (json['raga_examples'] as List<dynamic>? ?? [])
        .map((item) => VideoRecommendation.fromJson(item))
        .toList();
        
    final techniqueTutorials = (json['technique_tutorials'] as List<dynamic>? ?? [])
        .map((item) => VideoRecommendation.fromJson(item))
        .toList();

    return VideoRecommendations(
      skillImprovement: skillImprovement,
      ragaExamples: ragaExamples,
      techniqueTutorials: techniqueTutorials,
    );
  }
  
  bool get isEmpty => 
      skillImprovement.isEmpty && 
      ragaExamples.isEmpty && 
      techniqueTutorials.isEmpty;
}