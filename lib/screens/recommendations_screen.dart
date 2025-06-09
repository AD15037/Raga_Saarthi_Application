import 'package:flutter/material.dart';
import 'package:raga_saarthi/models/recommendation_model.dart';
import 'package:raga_saarthi/services/progress_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ProgressService _progressService = ProgressService();
  bool _isLoading = true;
  String? _errorMessage;
  RecommendationsResponse? _recommendations;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final recommendations = await _progressService.getRecommendations();

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_recommendations == null) {
      return const Center(
        child: Text('No recommendations available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Raga Recommendations Section
          const Text(
            'Recommended Ragas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRagaRecommendations(),
          const SizedBox(height: 32),

          // Practice Routine Section
          const Text(
            'Daily Practice Routine',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Text(
          //   '${_recommendations!.practiceRoutine.dailyPracticeTime} minutes',
          //   style: const TextStyle(
          //     fontSize: 16,
          //     color: Colors.deepPurple,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          const SizedBox(height: 12),
          _buildPracticeRoutine(),

          // Additional Advice
          if (_recommendations!.practiceRoutine.additionalAdvice != null)
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Instructor Advice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_recommendations!.practiceRoutine.additionalAdvice!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRagaRecommendations() {
    if (_recommendations!.ragaRecommendations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No raga recommendations available right now.'),
        ),
      );
    }

    return Column(
      children: _recommendations!.ragaRecommendations.map((rec) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      rec.raga,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rec.reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Future implementation: navigate to raga details
                      },
                      child: const Text('Learn More'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Future implementation: navigate to practice screen
                      },
                      child: const Text('Practice'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPracticeRoutine() {
    if (_recommendations!.practiceRoutine.exercises.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No practice routine available.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recommendations!.practiceRoutine.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _recommendations!.practiceRoutine.exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getImportanceColor(exercise.importance),
              child: Text(
                '${exercise.duration}m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(exercise.description),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getImportanceColor(String importance) {
    switch (importance.toLowerCase()) {
      case 'high':
        return Colors.deepPurple;
      case 'medium':
        return Colors.blueAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}