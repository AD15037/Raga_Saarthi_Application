import 'package:flutter/material.dart';
import 'package:raga_saarthi/models/progress_model.dart';
import 'package:raga_saarthi/services/progress_service.dart';
import 'package:raga_saarthi/widgets/progress_chart_widget.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _progressService = ProgressService();
  bool _isLoading = true;
  String? _errorMessage;
  ProgressResponse? _progressData;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final progressData = await _progressService.getUserProgress();

      setState(() {
        _progressData = progressData;
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
        title: const Text('Your Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgress,
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
              onPressed: _loadProgress,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_progressData == null) {
      return const Center(
        child: Text('No progress data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildSummaryCard(),
          const SizedBox(height: 24),

          // Performance Graph
          if (_progressData!.history.isNotEmpty) ...[
            const Text(
              'Performance Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ProgressChartWidget(
                history: _progressData!.history,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Skill Metrics
          const Text(
            'Skill Metrics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSkillMetricsCards(),
          const SizedBox(height: 24),

          // Recent Performances
          const Text(
            'Recent Performances',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentPerformances(),
          const SizedBox(height: 24),

          // Achievements
          // const Text(
          //   'Achievements',
          //   style: TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 16),
          // _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final metrics = _progressData!.metrics;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 24,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Key metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildMetricItem('Practice Sessions', metrics.sessionsCompleted, Icons.music_note)),
                Expanded(child: _buildMetricItem('Current Streak', metrics.currentStreak, Icons.local_fire_department)),
                Expanded(child: _buildMetricItem('Ragas Learned', metrics.ragasLearned, Icons.library_music)),
              ],
            ),
            const SizedBox(height: 16),

            // Skill level
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current Level: ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(metrics.skillLevel),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    metrics.skillLevel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // Improvement information
            if (metrics.improvement != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    metrics.improvement!.overallScore >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: metrics.improvement!.overallScore >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${metrics.improvement!.overallScore.toStringAsFixed(1)}% improvement over ${metrics.improvement!.daysPracticing} days',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: metrics.improvement!.overallScore >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillMetricsCards() {
    final skillMetrics = _progressData!.metrics.skillMetrics;

    return Column(
      children: [
        _buildSkillProgressCard(
          'Pitch Accuracy',
          skillMetrics.pitchAccuracy,
          Icons.graphic_eq,
          'Your ability to maintain accurate pitch throughout your performances',
        ),
        _buildSkillProgressCard(
          'Rhythm Stability',
          skillMetrics.rhythmStability,
          Icons.timer,
          'How consistently you maintain rhythm and tempo',
        ),
        _buildSkillProgressCard(
          'Gamaka Proficiency',
          skillMetrics.gamakaProfileiciency,
          Icons.waves,
          'Your skill with ornamentation and melodic embellishments',
        ),
        _buildSkillProgressCard(
          'Breath Control',
          skillMetrics.breathControl,
          Icons.air,
          'How well you manage breathing during performances',
        ),
      ],
    );
  }

  Widget _buildSkillProgressCard(String title, double value, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _getProgressColor(value)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(value)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPerformances() {
    if (_progressData!.history.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No performance history available yet.'),
          ),
        ),
      );
    }

    // Take only the 5 most recent performances
    final recentPerformances = _progressData!.history
        .take(5)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentPerformances.length,
      itemBuilder: (context, index) {
        final performance = recentPerformances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getProgressColor(performance.overallScore),
              child: Text(
                '${performance.overallScore.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              performance.raga,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('MMM d, yyyy • h:mm a').format(performance.date),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Aaroh: ${performance.aarohAdherence.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rhythm: ${performance.rhythmStability.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievements() {
    final achievements = _progressData!.metrics.achievements;

    if (achievements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Complete practice sessions to earn achievements!'),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: achievements.map((achievement) {
        return _buildAchievementItem(achievement);
      }).toList(),
    );
  }

  Widget _buildAchievementItem(String achievement) {
    String title;
    IconData iconData;
    // Explicitly type 'baseColor' as MaterialColor
    MaterialColor baseColor = Colors.amber; // Default base color

    // Map achievement IDs to user-friendly names and potentially different base colors
    switch (achievement) {
      case '7_day_streak':
        title = '7-Day Streak';
        iconData = Icons.local_fire_department;
        baseColor = Colors.red; // Example: Use red for streaks
        break;
      case '5_ragas_learned':
        title = '5 Ragas Learned';
        iconData = Icons.music_note;
        baseColor = Colors.green; // Example: Use green for ragas learned
        break;
      case '1_hour_milestone':
        title = '1 Hour Practice';
        iconData = Icons.timer;
        baseColor = Colors.blue; // Example: Use blue for time milestones
        break;
      default:
        title = achievement; // Use the achievement string as title if not mapped
        iconData = Icons.emoji_events; // Default icon
        baseColor = Colors.grey; // Default base color for unmapped achievements
        break;
    }

    return Container(
      width: 100,
      height: 100,
      child: Card(
        // Now use the shades from the explicitly typed MaterialColor
        color: baseColor.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: baseColor.shade700, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: baseColor.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 80) {
      return Colors.green;
    } else if (value >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'advanced':
        return Colors.purple;
      case 'intermediate':
        return Colors.blue;
      case 'beginner':
      default:
        return Colors.green;
    }
  }
}