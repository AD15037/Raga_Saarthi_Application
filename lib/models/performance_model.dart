import 'package:raga_saarthi/models/recommendation_model.dart';

class RagaPrediction {
  final String name;
  final double confidence;

  RagaPrediction({required this.name, required this.confidence});

  factory RagaPrediction.fromJson(Map<String, dynamic> json) {
    return RagaPrediction(
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class CNNPrediction {
  final List<RagaPrediction> predictedRagas;
  final String selectedRaga;
  final double matchConfidence;

  CNNPrediction({
    required this.predictedRagas,
    required this.selectedRaga,
    required this.matchConfidence,
  });

  factory CNNPrediction.fromJson(Map<String, dynamic> json) {
    final List<dynamic> predictionsList = json['predicted_ragas'] ?? [];
    final predictedRagas = predictionsList
        .map((item) => RagaPrediction.fromJson(item))
        .toList();

    return CNNPrediction(
      predictedRagas: predictedRagas,
      selectedRaga: json['selected_raga'] ?? '',
      matchConfidence: (json['match_confidence'] ?? 0.0).toDouble(),
    );
  }
}

class ScoreBasis {
  final String basedOn;
  final String selectedRaga;
  final String? predictedRaga;

  ScoreBasis({
    required this.basedOn,
    required this.selectedRaga,
    this.predictedRaga,
  });

  factory ScoreBasis.fromJson(Map<String, dynamic> json) {
    return ScoreBasis(
      basedOn: json['based_on'] ?? 'selected_raga',
      selectedRaga: json['selected_raga'] ?? '',
      predictedRaga: json['predicted_raga'],
    );
  }
}

class PerformanceResult {
  final double overallScore;
  final Map<String, double> structureAdherence;
  final double vadiSamvadiAccuracy;
  final double rhythmStability;
  final double? pronunciationScore;
  final Map<String, dynamic> detectedPatterns;
  final List<Map<String, String>> feedback;
  VideoRecommendations? videoRecommendations;
  final Map<String, dynamic> vocalCharacteristics;
  final Map<String, dynamic>? analysis;
  final CNNPrediction? cnnPrediction; // Add CNN prediction
  final String predictedRaga; // Store the predicted raga name
  final ScoreBasis? scoreBasis;

  PerformanceResult({
    required this.overallScore,
    required this.structureAdherence,
    required this.vadiSamvadiAccuracy,
    required this.rhythmStability,
    required this.detectedPatterns,
    required this.feedback,
    this.pronunciationScore,
    this.videoRecommendations,
    required this.vocalCharacteristics,
    this.analysis,
    this.cnnPrediction,
    required this.predictedRaga,
    this.scoreBasis,
  });

  factory PerformanceResult.fromJson(Map<String, dynamic> json) {
    // Parse structure adherence
    final structureAdherence = <String, double>{};
    if (json['structure_adherence'] != null) {
      json['structure_adherence'].forEach((key, value) {
        structureAdherence[key] = value.toDouble();
      });
    }

    // Parse feedback
    final feedback = <Map<String, String>>[];
    if (json['feedback'] != null) {
      for (var item in json['feedback']) {
        feedback.add({
          'type': item['type'] ?? '',
          'area': item['area'] ?? '',
          'message': item['message'] ?? '',
        });
      }
    }

    // Parse video recommendations
    VideoRecommendations? videoRecommendations;
    if (json['video_recommendations'] != null) {
      videoRecommendations = VideoRecommendations.fromJson(json['video_recommendations']);
    }

    // Parse CNN prediction
    CNNPrediction? cnnPrediction;
    if (json['cnn_prediction'] != null) {
      cnnPrediction = CNNPrediction.fromJson(json['cnn_prediction']);
    }

    // Parse score basis
    ScoreBasis? scoreBasis;
    if (json['score_basis'] != null) {
      scoreBasis = ScoreBasis.fromJson(json['score_basis']);
    }

    // Get predicted raga or default to selected raga
    String predictedRaga = json['predicted_raga'] ?? json['raga'] ?? '';

    return PerformanceResult(
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
      structureAdherence: structureAdherence,
      vadiSamvadiAccuracy: (json['vadi_samvadi_accuracy'] ?? 0.0).toDouble(),
      rhythmStability: (json['rhythm_stability'] ?? 0.0).toDouble(),
      pronunciationScore: json['pronunciation_score']?.toDouble(),
      detectedPatterns: json['detected_patterns'] ?? {},
      feedback: feedback,
      videoRecommendations: videoRecommendations,
      vocalCharacteristics: json['vocal_characteristics'] ?? {},
      analysis: json['analysis'],
      cnnPrediction: cnnPrediction,
      predictedRaga: predictedRaga,
      scoreBasis: scoreBasis,
    );
  }
}