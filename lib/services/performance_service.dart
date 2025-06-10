import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:raga_saarthi/config.dart';
import 'package:raga_saarthi/models/performance_model.dart';
import 'package:raga_saarthi/models/recommendation_model.dart';

class PerformanceService {
  Future<Map<String, dynamic>> analyzePerformance(File audioFile, String raga) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookieHeader = prefs.getString('cookie_header');

      if (cookieHeader == null) {
        return {
          'success': false,
          'message': 'You need to be logged in to analyze performances',
        };
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiBaseUrl}${Config.analyzePerformanceEndpoint}'),
      );

      // Add cookie header for authentication
      request.headers['Cookie'] = cookieHeader;

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      ));

      // Add raga information
      request.fields['raga'] = raga;

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Create the performance result with performance data
        var performanceResult = PerformanceResult.fromJson(responseData['performance']);

        // Add vocal characteristics to the performance result
        // This uses a copy constructor or manually setting the field depending on your implementation
        if (responseData['vocal_characteristics'] != null) {
          // Create a new instance with all existing data plus vocal characteristics
          performanceResult = PerformanceResult(
            overallScore: performanceResult.overallScore,
            structureAdherence: performanceResult.structureAdherence,
            vadiSamvadiAccuracy: performanceResult.vadiSamvadiAccuracy,
            rhythmStability: performanceResult.rhythmStability,
            detectedPatterns: performanceResult.detectedPatterns,
            feedback: performanceResult.feedback,
            pronunciationScore: performanceResult.pronunciationScore,
            videoRecommendations: performanceResult.videoRecommendations,
            vocalCharacteristics: responseData['vocal_characteristics'],
          );
        }

        // Add video recommendations to the performance result
        if (responseData['video_recommendations'] != null) {
          performanceResult.videoRecommendations = VideoRecommendations.fromJson(responseData['video_recommendations']);
        }

        return {
          'success': true,
          'result': performanceResult,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to analyze performance',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}