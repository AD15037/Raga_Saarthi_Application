import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:raga_saarthi/screens/performance_results_screen.dart';
import 'package:raga_saarthi/services/performance_service.dart';

import '../models/performance_model.dart';

class RecordScreen extends StatefulWidget {
  final String? initialRaga;
  
  const RecordScreen({Key? key, this.initialRaga}) : super(key: key);

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _audioRecorder = Record();
  final _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  String? _audioPath;
  bool _isUploadedFile = false;

  String _selectedRaga = 'Abhogi Kanada'; // Default raga
  bool _isAnalyzing = false;

  final List<String> _ragas = [
    'Abhogi Kanada','Adana','Aheer Bhairav','Alhaiya Bilawal','Bageshree','Bahar','Bairagi','Bairagi Todi','Basant',
    'Basant Mukhari','Bhairav','Bhairavi','Bhatiyar','Bheem','Bheempalasi','Bhoopali','Bhupal Todi','Bihag','Bihagda',
    'Bilaskhani Todi','Chandrakauns','Charukeshi','Chhayanut','Darbari Kanada','Des','Deshkar','Desi','Dev Gandhar',
    'Devgiri Bilawal','Devshree','Dhanashree (Bhairavi Ang)','Dhani','Durga','Gaud Malhar','Gaud Sarang','Gauri (Bhairav Ang)',
    'Gopika Basant','Gorakh Kalyan','Gunkali','Gurjari Todi','Hameer','Hansdhwani','Hanskinkini','Harikauns','Hemant','Hemshree',
    'Hindol','Jaijaivanti','Jaldhar Kedar','Jaunpuri','Jayat','Jhinjhoti','Jog','Jogeshwari','Pancham Jogeshwari','Jogiya',
    'Jogkauns','Kafi','Kalawati','Kamod','Kaushik Dhwani','Kausi Kanada','Kedar','Khamaj','Khambavati','Kirwani',
    'Komal Rishabh Asawari','Lalit','Lanka Dahan Sarang','Madhukauns','Madhumad Sarang','Madhuvanti','Malgunji','Malhar',
    'Malkauns','Mand','Maru Bihag','Marwa','Megh Malhar','Mohankauns','Multani','Nand','Narayani','Nayaki Kanada','Nut Bhairav',
    'Parameshwari','Patdeep','Pilu','Puriya','Puriya Dhanashree','Puriya Kalyan','Poorvi','Ragashree','Ramdasi Malhar',
    'Ramkali','Saalag Varali','Sarang (Brindavani Sarang)','Saraswati','Saraswati Kedar','Shahana Kanada','Shankara',
    'Shivranjani','Shobhawari','Shree','Shuddha Kalyan','Shuddha Sarang','Shyam Kalyan','Sindhura','Sohani','Suha Sughrai',
    'Sundarkali','Sundarkauns','Surdasi Malhar','Tilak Kamod','Tilang','Tilang Bahar','Todi','Vachaspati','Vibhas','Yaman'
  ];

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialRaga != null) {
      _selectedRaga = widget.initialRaga!;
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to record'),
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      await _requestPermissions();

      if (await _audioRecorder.hasPermission()) {
        // Reset any uploaded file state
        setState(() {
          _isUploadedFile = false;
        });

        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          path: path,
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100,
        );

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _audioPath = path;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      setState(() => _isPaused = true);
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      setState(() => _isPaused = false);
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      // Make sure we're not recording
      if (_isRecording) {
        await _stopRecording();
      }

      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // Check if file is a WAV file (required by backend)
        if (!filePath.toLowerCase().endsWith('.wav')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a WAV audio file'),
            ),
          );
          return;
        }

        setState(() {
          _audioPath = filePath;
          _isUploadedFile = true;
        });

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected file: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error picking audio file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting audio file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath != null) {
      try {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
        setState(() => _isPlaying = true);

        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() => _isPlaying = false);
        });
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  Future<void> _analyzePerformance() async {
    if (_audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record or upload an audio file first'),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final performanceService = PerformanceService();
      final result = await performanceService.analyzePerformance(
        File(_audioPath!),
        _selectedRaga,
      );

      setState(() => _isAnalyzing = false);

      if (result['success']) {
        final performanceResult = result['result'] as PerformanceResult;

        // Navigate to results screen with the performance result
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerformanceResultsScreen(
              result: performanceResult,
              raga: performanceResult.predictedRaga, // Use the predicted raga from the model
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing performance: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Performance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Raga selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Raga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: _selectedRaga,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRaga = value);
                        }
                      },
                      items: _ragas.map((raga) {
                        return DropdownMenuItem<String>(
                          value: raga,
                          child: Text(raga),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Audio source options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.mic),
                    label: const Text('Record Audio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: !_isUploadedFile ? Colors.deepPurple : null,
                      foregroundColor: !_isUploadedFile ? Colors.white : null,
                    ),
                    onPressed: _isRecording ? null : () async {
                      setState(() {
                        _isUploadedFile = false;
                        _audioPath = null;
                      });
                      // Start recording immediately when this button is pressed
                      await _startRecording();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: _isUploadedFile ? Colors.deepPurple : null,
                      foregroundColor: _isUploadedFile ? Colors.white : null,
                    ),
                    onPressed: _isRecording ? null : _pickAudioFile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recording section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isUploadedFile ? 'Uploaded Audio' : 'Recording',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Audio visualization
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? Colors.red.shade100
                            : _isUploadedFile
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _isRecording
                            ? const Icon(Icons.graphic_eq, size: 48, color: Colors.red)
                            : _isUploadedFile
                            ? const Icon(Icons.audio_file, size: 48, color: Colors.blue)
                            : const Icon(Icons.mic, size: 48, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // File name display (for uploaded files)
                    if (_isUploadedFile && _audioPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'File: ${_audioPath!.split('/').last}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Recording controls - show only when not using uploaded file
                    if (!_isUploadedFile)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Record / Stop button
                            FloatingActionButton(
                              backgroundColor: _isRecording ? Colors.red : Colors.deepPurple,
                              onPressed: _isRecording ? _stopRecording : _startRecording,
                              child: Icon(_isRecording ? Icons.stop : Icons.mic),
                            ),

                            // Pause / Resume button (only visible when recording)
                            if (_isRecording)
                              FloatingActionButton(
                                backgroundColor: Colors.orangeAccent,
                                onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                                child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                              ),
                          ],
                        ),
                      ),

                    // Playback controls - show when we have audio (recorded or uploaded)
                    if ((_audioPath != null && !_isRecording))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton.icon(
                          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(_isPlaying ? 'Stop' : 'Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _isPlaying ? _stopPlayback : _playAudio,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Analyze button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white, // Force white text regardless of state
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isAnalyzing ? null : _analyzePerformance,
                child: _isAnalyzing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, // Force white color for the spinner
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                              color: Colors.white, // Force white text during analysis
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Analyze Performance',
                        style: TextStyle(
                          color: Colors.white, // Force white text always
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoRecommendation {
  final String title;
  final String url;
  final String thumbnail;

  VideoRecommendation({
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  factory VideoRecommendation.fromJson(Map<String, dynamic> json) {
    return VideoRecommendation(
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
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