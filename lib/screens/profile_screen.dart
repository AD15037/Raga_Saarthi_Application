import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raga_saarthi/screens/login_screen.dart';
import 'package:raga_saarthi/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await authService.logout();
                // Navigate to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            _buildProfileHeader(user.username, user.skillLevel),
            const SizedBox(height: 24),

            // Stats section
            _buildStatsSection(user),
            const SizedBox(height: 24),

            // Ragas practiced
            _buildRagasPracticedSection(user),
            const SizedBox(height: 24),

            // Achievements
            _buildAchievementsSection(user),
            const SizedBox(height: 24),

            // Preferences
            _buildPreferencesSection(user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String username, String skillLevel) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture (placeholder)
            const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Username
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Skill level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _getSkillLevelColor(skillLevel),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skillLevel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Edit profile button
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              onPressed: () {
                // To be implemented in a future update
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile editing will be available in a future update.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatRow(
                  'Practice Sessions',
                  '${user.practiceSessions}',
                  Icons.music_note,
                ),
                const Divider(),
                _buildStatRow(
                  'Total Practice Time',
                  '${user.totalPracticeTime} mins',
                  Icons.timer,
                ),
                const Divider(),
                _buildStatRow(
                  'Practice Streak',
                  '${user.practiceStreak} days',
                  Icons.local_fire_department,
                ),
                const Divider(),
                _buildStatRow(
                  'Ragas Learned',
                  '${user.ragasPracticed.length}',
                  Icons.library_music,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
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

  Widget _buildRagasPracticedSection(dynamic user) {
    final ragas = user.ragasPracticed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ragas You\'ve Practiced',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ragas.isEmpty
            ? const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'You haven\'t practiced any ragas yet. Record your first performance!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ragas.map<Widget>((raga) {
            return Chip(
              backgroundColor: Colors.deepPurple.shade100,
              label: Text(raga),
              avatar: const Icon(Icons.music_note, size: 16),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(dynamic user) {
    final achievements = user.achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        achievements.isEmpty
            ? const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Complete practice sessions to earn achievements!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
            : SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: achievements.map((achievement) {
              return _buildAchievementItem(achievement);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(String achievement) {
    String title;
    IconData iconData;

    // Map achievement IDs to user-friendly names
    switch (achievement) {
      case '7_day_streak':
        title = '7-Day Streak';
        iconData = Icons.local_fire_department;
        break;
      case '5_ragas_learned':
        title = '5 Ragas Learned';
        iconData = Icons.music_note;
        break;
      case '1_hour_milestone':
        title = '1 Hour Practice';
        iconData = Icons.timer;
        break;
      default:
        title = achievement;
        iconData = Icons.emoji_events;
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Colors.amber.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.amber.shade700, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(dynamic user) {
    final preferredRagas = user.preferredRagas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferred Ragas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                preferredRagas.isEmpty
                    ? const Text(
                  'You haven\'t set any preferred ragas yet.',
                  style: TextStyle(color: Colors.grey),
                )
                    : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: preferredRagas.map<Widget>((raga) {
                    return Chip(
                      backgroundColor: Colors.blue.shade100,
                      label: Text(raga),
                      onDeleted: () {
                        // To be implemented in a future update
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preference editing will be available in a future update.'),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Preferred Raga'),
                    onPressed: () {
                      // To be implemented in a future update
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preference editing will be available in a future update.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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