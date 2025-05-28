import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raga_saarthi/config.dart';
import 'package:raga_saarthi/models/progress_model.dart';
import 'package:raga_saarthi/models/recommendation_model.dart';

class ProgressService {
  Future<ProgressResponse> getUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookieHeader = prefs.getString('cookie_header');

      if (cookieHeader == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}${Config.progressEndpoint}'),
        headers: {
          'Cookie': cookieHeader,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProgressResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['error'] ?? 'Failed to load progress data');
      }
    } catch (e) {
      throw Exception('Error fetching progress data: $e');
    }
  }

  Future<RecommendationsResponse> getRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookieHeader = prefs.getString('cookie_header');

      if (cookieHeader == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}${Config.recommendationsEndpoint}'),
        headers: {
          'Cookie': cookieHeader,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return RecommendationsResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['error'] ?? 'Failed to load recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}