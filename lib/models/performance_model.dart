import 'package:raga_saarthi/models/recommendation_model.dart';

class PerformanceResult {
  final double overallScore;
  final Map<String, double> structureAdherence;
  final double vadiSamvadiAccuracy;
  final double rhythmStability;
  final double? pronunciationScore;
  final Map<String, dynamic> detectedPatterns;
  final List<Map<String, String>> feedback;
  VideoRecommendations? videoRecommendations;
  final Map<String, dynamic> vocalCharacteristics; // Added this field

  PerformanceResult({
    required this.overallScore,
    required this.structureAdherence,
    required this.vadiSamvadiAccuracy,
    required this.rhythmStability,
    required this.detectedPatterns,
    required this.feedback,
    this.pronunciationScore,
    this.videoRecommendations,
    required this.vocalCharacteristics, // Added parameter
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
    );
  }
}