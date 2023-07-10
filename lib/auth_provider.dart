import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _loggedIn = false;
  ApiService _apiService = ApiService();

  bool get loggedIn => _loggedIn;

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);

    if (data['success']) {
      _loggedIn = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'].toString());
      await prefs.setString('expiresAt', data['expiresAt'].toString());
      notifyListeners();
    } else {
      throw Exception(data['message']);
    }
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? expiresAt = prefs.getString('expiresAt');

    if (token != null && expiresAt != null) {
      DateTime expiryDate = DateTime.parse(expiresAt);
      if (expiryDate.isAfter(DateTime.now())) {
        _loggedIn = true;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    _loggedIn = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('expiresAt');
    notifyListeners();
  }
}
