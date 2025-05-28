class PerformanceResult {
  final double overallScore;
  final Map<String, double> structureAdherence;
  final double vadiSamvadiAccuracy;
  final double rhythmStability;
  final double? pronunciationScore;
  final Map<String, dynamic> detectedPatterns;
  final List<Map<String, dynamic>> feedback;
  final Map<String, dynamic> vocalCharacteristics;
  final Map<String, dynamic>? analysis;
  final String? transcription;

  PerformanceResult({
    required this.overallScore,
    required this.structureAdherence,
    required this.vadiSamvadiAccuracy,
    required this.rhythmStability,
    this.pronunciationScore,
    required this.detectedPatterns,
    required this.feedback,
    required this.vocalCharacteristics,
    this.analysis,
    this.transcription,
  });

  factory PerformanceResult.fromJson(Map<String, dynamic> json) {
    final performanceData = json['performance'];

    return PerformanceResult(
      overallScore: performanceData['overall_score'].toDouble(),
      structureAdherence: Map<String, double>.from(
        performanceData['structure_adherence'].map(
              (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      vadiSamvadiAccuracy: performanceData['vadi_samvadi_accuracy'].toDouble(),
      rhythmStability: performanceData['rhythm_stability'].toDouble(),
      pronunciationScore: performanceData['pronunciation_score']?.toDouble(),
      detectedPatterns: performanceData['detected_patterns'],
      feedback: List<Map<String, dynamic>>.from(performanceData['feedback']),
      vocalCharacteristics: json['vocal_characteristics'],
      analysis: json['analysis'],
      transcription: json['transcription'],
    );
  }
}