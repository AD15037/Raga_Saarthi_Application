import 'package:flutter/material.dart';
import 'package:raga_saarthi/models/performance_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raga_saarthi/models/recommendation_model.dart';
import 'package:raga_saarthi/config.dart';

class PerformanceResultsScreen extends StatefulWidget {
  final PerformanceResult result;
  final String raga;

  const PerformanceResultsScreen({
    Key? key,
    required this.result,
    required this.raga,
  }) : super(key: key);

  @override
  _PerformanceResultsScreenState createState() => _PerformanceResultsScreenState();
}

class _PerformanceResultsScreenState extends State<PerformanceResultsScreen> {
  int _selectedGraphIndex = 0;
  final List<String> _graphTitles = [
    'Waveform',
    'Spectrogram',
    'Pitch Contour',
    'Pitch Histogram',
    'Amplitude Spectrum',
    'Periodogram',
    'Histogram',
    'Autocorrelation',
    'FFT Plot',
    'Power Spectral Density',
    'Normalized Periodogram',
  ];

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
              color: _getScoreColor(widget.result.overallScore),
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
                      '${widget.result.overallScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Raga: ${widget.raga}',
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

            // Audio visualization section (new)
            if (widget.result.analysis != null && 
                widget.result.analysis!['graphs'] != null) ...[
              const Text(
                'Audio Visualization',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAudioVisualization(),
              const SizedBox(height: 24),
            ],

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
              widget.result.structureAdherence['aaroh'] ?? 0,
              Icons.arrow_upward,
            ),
            _buildScoreCard(
              'Avroh Adherence',
              widget.result.structureAdherence['avroh'] ?? 0,
              Icons.arrow_downward,
            ),
            _buildScoreCard(
              'Pakad Adherence',
              widget.result.structureAdherence['pakad'] ?? 0,
              Icons.repeat,
            ),
            _buildScoreCard(
              'Vadi-Samvadi Accuracy',
              widget.result.vadiSamvadiAccuracy,
              Icons.music_note,
            ),
            _buildScoreCard(
              'Rhythm Stability',
              widget.result.rhythmStability,
              Icons.timer,
            ),
            if (widget.result.pronunciationScore != null)
              _buildScoreCard(
                'Pronunciation',
                widget.result.pronunciationScore!,
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
            ...widget.result.feedback.map((feedback) => _buildFeedbackCard(feedback)),
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
            _buildVideoRecommendations(context),
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
    final vocalRange = widget.result.vocalCharacteristics['vocal_range'];
    final timbre = widget.result.vocalCharacteristics['timbre'];
    final stability = widget.result.vocalCharacteristics['stability'];
    final breathControl = widget.result.vocalCharacteristics['breath_control'] * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vocal range
            Row(
              children: [
                const Text(
                  'Vocal Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  onPressed: () => _showNotationGuide(context),
                  tooltip: 'Notation Guide',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _characteristicItemWithTooltip(
                  'Min', 
                  vocalRange['min_note'] ?? '-', 
                  'Lowest note in your vocal range\n\nThe symbol ",S" means S in the lower octave'
                ),
                _characteristicItemWithTooltip(
                  'Max', 
                  vocalRange['max_note'] ?? '-',
                  'Highest note in your vocal range\n\nThe symbol "S\'" means S in the upper octave'
                ),
                _characteristicItemWithTooltip(
                  'Avg', 
                  vocalRange['mean_note'] ?? '-',
                  'Average note in your vocal range\n\nPlain symbols like "D" indicate middle octave'
                ),
              ],
            ),
            
            // Notation hint text
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Note: Symbols show Indian classical notation (S, R, G, M, P, D, N). Tap "i" for details.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
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

  Widget _characteristicItemWithTooltip(String label, String value, String tooltip) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        padding: const EdgeInsets.all(8),
        preferBelow: true,
        showDuration: const Duration(seconds: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
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
      ),
    );
  }

  Widget _buildVideoRecommendations(BuildContext context) {
    if (widget.result.videoRecommendations == null || widget.result.videoRecommendations!.isEmpty) {
      return const SizedBox.shrink(); // No recommendations to show
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Video Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Skill improvement videos
        if (widget.result.videoRecommendations!.skillImprovement.isNotEmpty) ...[
          const Text(
            'Improve Your Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.result.videoRecommendations!.skillImprovement
              .map((video) => _buildVideoCard(video, context))
              .toList(),
          const SizedBox(height: 16),
        ],

        // Raga examples
        if (widget.result.videoRecommendations!.ragaExamples.isNotEmpty) ...[
          const Text(
            'Raga Examples',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.result.videoRecommendations!.ragaExamples
              .map((video) => _buildVideoCard(video, context))
              .toList(),
          const SizedBox(height: 16),
        ],

        // Technique tutorials
        if (widget.result.videoRecommendations!.techniqueTutorials.isNotEmpty) ...[
          const Text(
            'Technique Tutorials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.result.videoRecommendations!.techniqueTutorials
              .map((video) => _buildVideoCard(video, context))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildVideoCard(VideoRecommendation video, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
        title: Text(
          video.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(video.description),
            if (video.score != null) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: video.score! / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(video.score!)),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchURL(video.url, context),
      ),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the video link')),
      );
    }
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

  Widget _buildAudioVisualization() {
    final graphs = widget.result.analysis!['graphs'] as Map<String, dynamic>;
    
    // Get graph URLs from the analysis data
    final graphKeys = {
      'Waveform': 'waveform',
      'Spectrogram': 'spectrogram',
      'Pitch Contour': 'pitch_contour',
      'Pitch Histogram': 'pitch_histogram',
      'Amplitude Spectrum': 'spectrum',
      'Periodogram': 'periodogram', 
      'Histogram': 'histogram',
      'Autocorrelation': 'autocorrelation',
      'FFT Plot': 'fft_plot',
      'Power Spectral Density': 'psd',
      'Normalized Periodogram': 'normalized_periodogram',
    };
    
    return Column(
      children: [
        // Graph selection chips
        SizedBox(
          height: 60, // Increased height a bit
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _graphTitles.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    _graphTitles[index],
                    style: TextStyle(
                      fontSize: 13, // Slightly smaller font size for longer titles
                      fontWeight: _selectedGraphIndex == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: _selectedGraphIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGraphIndex = index;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Graph display
        Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _graphTitles[_selectedGraphIndex],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGraphDescription(_graphTitles[_selectedGraphIndex]),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 250,
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildGraph(graphs, graphKeys[_graphTitles[_selectedGraphIndex]] ?? ''),
              ),
              // Add a hint about interactivity
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Tap on the graph to view fullscreen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenGraph(String graphUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                graphUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(Map<String, dynamic> graphs, String graphKey) {
    if (graphKey.isEmpty || !graphs.containsKey(graphKey)) {
      return const Center(child: Text('Graph not available'));
    }

    final graphUrl = '${Config.apiBaseUrl}${graphs[graphKey]}';
    
    return GestureDetector(
      onTap: () => _showFullScreenGraph(graphUrl, _graphTitles[_selectedGraphIndex]),
      child: Center(
        child: Image.network(
          graphUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Try an alternative path if the original URL fails
            // This adds robustness in case the backend format changes
            String fixedUrl = graphUrl;
            if (!graphUrl.contains('/static/') && graphUrl.contains('/graphs/')) {
              fixedUrl = graphUrl.replaceAll('/graphs/', '/static/graphs/');
              
              // Return Image with the fixed URL
              return Image.network(
                fixedUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // If even the fixed URL fails, show an error
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 32, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Failed to load graph: $error'),
                    ],
                  );
                },
              );
            }
            
            // Original error view if the URL format doesn't match the pattern
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 32, color: Colors.red),
                const SizedBox(height: 8),
                Text('Failed to load graph: $error'),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getGraphDescription(String title) {
    final descriptions = {
      'Waveform': 'Shows amplitude changes over time in your audio recording.',
      'Spectrogram': 'Visualizes frequency content of the audio over time.',
      'Pitch Contour': 'Shows how your pitch (frequency) changes throughout the performance.',
      'Pitch Histogram': 'Distribution of different pitch classes used in your performance.',
      'Amplitude Spectrum': 'Shows the frequency components of your audio in the frequency domain.',
      'Periodogram': 'Power spectral density estimate showing signal strength vs frequency.',
      'Histogram': 'Distribution of amplitude values in your audio recording.',
      'Autocorrelation': 'Shows how your signal correlates with itself over time.',
      'FFT Plot': 'Fast Fourier Transform showing frequency spectrum of your performance.',
      'Power Spectral Density': 'Energy distribution across frequencies using Welch\'s method.',
      'Normalized Periodogram': 'Periodogram with normalized frequency representation.',
    };
    
    return descriptions[title] ?? 'Visualization of audio characteristics.';
  }

  // Add this method to show a detailed notation guide
  void _showNotationGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Indian Classical Music Notation Guide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotationSection('Basic Notes (Swaras)', [
                _buildNotationRow('S', 'Shadja (Sa)'),
                _buildNotationRow('R', 'Shuddha Rishabh (Re)'),
                _buildNotationRow('r', 'Komal Rishabh (Re flat)'),
                _buildNotationRow('G', 'Shuddha Gandhar (Ga)'),
                _buildNotationRow('g', 'Komal Gandhar (Ga flat)'),
                _buildNotationRow('M', 'Shuddha Madhyam (Ma)'),
                _buildNotationRow('m', 'Tivra Madhyam (Ma sharp)'),
                _buildNotationRow('P', 'Pancham (Pa)'),
                _buildNotationRow('D', 'Shuddha Dhaivat (Dha)'),
                _buildNotationRow('d', 'Komal Dhaivat (Dha flat)'),
                _buildNotationRow('N', 'Shuddha Nishad (Ni)'),
                _buildNotationRow('n', 'Komal Nishad (Ni flat)'),
              ]),
              const SizedBox(height: 16),
              _buildNotationSection('Octave Indicators', [
                _buildNotationRow(',S', 'Lower octave (e.g., ,S is Sa in lower octave)'),
                _buildNotationRow('S', 'Middle octave (default, no special symbol)'),
                _buildNotationRow('S\'', 'Upper octave (e.g., S\' is Sa in upper octave)'),
              ]),
              const SizedBox(height: 16),
              Text(
                'Your vocal range is shown using these notations, indicating the lowest, highest, and average notes you performed.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotationSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildNotationRow(String symbol, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 30,
            child: Text(
              symbol,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}