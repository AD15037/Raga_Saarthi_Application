import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raga_saarthi/config.dart';
import 'package:raga_saarthi/models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final cookieHeader = prefs.getString('cookie_header');

    if (cookieHeader != null) {
      try {
        // Try to get user profile with saved cookie
        final response = await http.get(
          Uri.parse('${Config.apiBaseUrl}${Config.profileEndpoint}'),
          headers: {
            'Cookie': cookieHeader,
          },
        );

        if (response.statusCode == 200) {
          _currentUser = User.fromJson(jsonDecode(response.body));
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('Error checking login status: $e');
      }
    }

    return false;
  }

  // Register new user
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}${Config.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save cookie for session
        _saveCookie(response);

        // Get user profile after registration
        await isLoggedIn();

        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to register',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}${Config.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save cookie for session
        _saveCookie(response);

        // Set current user
        _currentUser = User.fromJson(responseData['profile']);
        notifyListeners();

        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookieHeader = prefs.getString('cookie_header');

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}${Config.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookieHeader ?? '',
        },
      );

      if (response.statusCode == 200) {
        // Clear cookie and user data
        await prefs.remove('cookie_header');
        _currentUser = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  // Helper method to save Flask session cookie
  Future<void> _saveCookie(http.Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cookie_header', cookies);
    }
  }
}