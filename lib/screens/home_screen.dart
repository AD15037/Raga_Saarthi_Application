import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raga_saarthi/screens/login_screen.dart';
import 'package:raga_saarthi/screens/profile_screen.dart';
import 'package:raga_saarthi/screens/progress_screen.dart';
import 'package:raga_saarthi/screens/recommendations_screen.dart';
import 'package:raga_saarthi/screens/record_screen.dart';
import 'package:raga_saarthi/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _HomeContent(onQuickActionSelected: _onItemTapped),
      const RecordScreen(),
      const RecommendationsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Recommendations'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final void Function(int) onQuickActionSelected;

  const _HomeContent({required this.onQuickActionSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raag Saarthi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final result = await authService.logout();
              if (result) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Skill Level: ${user.skillLevel.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Sessions',
                          value: user.practiceSessions.toString(),
                          icon: Icons.music_note,
                        ),
                        _StatItem(
                          label: 'Streak',
                          value: user.practiceStreak.toString(),
                          icon: Icons.local_fire_department,
                        ),
                        _StatItem(
                          label: 'Ragas',
                          value: user.ragasPracticed.length.toString(),
                          icon: Icons.auto_awesome,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.mic,
              label: 'Record Performance',
              description: 'Practice a raga and get feedback',
              onTap: () => onQuickActionSelected(1),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.lightbulb,
              label: 'View Recommendations',
              description: 'Get personalized raga suggestions',
              onTap: () => onQuickActionSelected(2),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.deepPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final String achievement;

  const _AchievementItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
    String title;
    IconData iconData;

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
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Colors.amber.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.amber.shade700, size: 32),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
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
}