import 'package:flutter/material.dart';
import 'package:raga_saarthi/models/performance_model.dart';

class PerformanceResultsScreen extends StatelessWidget {
  final PerformanceResult result;
  final String raga;

  const PerformanceResultsScreen({
    Key? key,
    required this.result,
    required this.raga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall score card
            Card(
              elevation: 4,
              color: _getScoreColor(result.overallScore),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Overall Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.overallScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Raga: $raga',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detailed scores
            const Text(
              'Detailed Scores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              'Aaroh Adherence',
              result.structureAdherence['aaroh'] ?? 0,
              Icons.arrow_upward,
            ),
            _buildScoreCard(
              'Avroh Adherence',
              result.structureAdherence['avroh'] ?? 0,
              Icons.arrow_downward,
            ),
            _buildScoreCard(
              'Pakad Adherence',
              result.structureAdherence['pakad'] ?? 0,
              Icons.repeat,
            ),
            _buildScoreCard(
              'Vadi-Samvadi Accuracy',
              result.vadiSamvadiAccuracy,
              Icons.music_note,
            ),
            _buildScoreCard(
              'Rhythm Stability',
              result.rhythmStability,
              Icons.timer,
            ),
            if (result.pronunciationScore != null)
              _buildScoreCard(
                'Pronunciation',
                result.pronunciationScore!,
                Icons.record_voice_over,
              ),
            const SizedBox(height: 24),

            // Feedback section
            const Text(
              'Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...result.feedback.map((feedback) => _buildFeedbackCard(feedback)),
            const SizedBox(height: 24),

            // Vocal characteristics
            const Text(
              'Vocal Characteristics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildVocalCharacteristics(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: _getScoreColor(score)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    IconData icon;
    switch (feedback['type']) {
      case 'structure':
        icon = Icons.architecture;
        break;
      case 'emphasis':
        icon = Icons.priority_high;
        break;
      case 'rhythm':
        icon = Icons.timer;
        break;
      case 'pronunciation':
        icon = Icons.record_voice_over;
        break;
      default:
        icon = Icons.lightbulb;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback['area'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(feedback['message']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocalCharacteristics() {
    final vocalRange = result.vocalCharacteristics['vocal_range'];
    final timbre = result.vocalCharacteristics['timbre'];
    final stability = result.vocalCharacteristics['stability'];
    final breathControl = result.vocalCharacteristics['breath_control'] * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vocal range
            const Text(
              'Vocal Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _characteristicItem('Min', vocalRange['min_note'] ?? '-'),
                _characteristicItem('Max', vocalRange['max_note'] ?? '-'),
                _characteristicItem('Avg', vocalRange['mean_note'] ?? '-'),
              ],
            ),
            const Divider(),

            // Timbre
            const Text(
              'Timbre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _characteristicItem(
                  'Brightness',
                  '${(timbre['brightness'] * 100).toStringAsFixed(1)}%',
                ),
                _characteristicItem(
                  'Roughness',
                  '${(timbre['roughness'] * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
            const Divider(),

            // Stability
            const Text(
              'Stability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _characteristicItem(
                  'Pitch',
                  '${(stability['pitch_stability'] * 100).toStringAsFixed(1)}%',
                ),
                _characteristicItem(
                  'Vibrato',
                  '${stability['vibrato_rate'].toStringAsFixed(1)} Hz',
                ),
              ],
            ),
            const Divider(),

            // Breath control
            const Text(
              'Breath Control',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: breathControl / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(breathControl),
              ),
              minHeight: 10,
            ),
            const SizedBox(height: 4),
            Text(
              '${breathControl.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(breathControl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _characteristicItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}