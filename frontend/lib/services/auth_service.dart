import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _userId?.substring(0, 8); // Temporary - replace with actual username
  String? get profilePicture => null; // Temporary - replace with actual profile picture

  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://localhost:5000/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        _token = responseData['token'];
        _userId = responseData['userId'];
        _email = email;
        notifyListeners();
      } else {
        throw Exception(responseData['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String username) async {
    final url = Uri.parse('http://localhost:5000/api/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        _token = responseData['token'];
        _userId = responseData['userId'];
        _email = email;
        notifyListeners();
      } else {
        throw Exception(responseData['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _email = null;
    notifyListeners();
  }
}