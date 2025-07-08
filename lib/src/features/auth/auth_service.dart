import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/token_storage.dart';

class AuthService {
  static Map<String, dynamic>? _currentUser;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static Map<String, dynamic>? get currentUser => _currentUser;

  // Set navigator key for global navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    // Set the session expiration callback
    ApiService.onSessionExpired = _handleSessionExpired;
  }

  // Handle session expiration
  static void _handleSessionExpired() {
    _currentUser = null;
    
    // Navigate to login page if navigator is available
    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  // Check if user is logged in by checking stored token
  static Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }

  // Initialize auth state (call this on app start)
  static Future<void> initializeAuth() async {
    final userData = await TokenStorage.getUserData();
    if (userData != null) {
      try {
        _currentUser = jsonDecode(userData);
      } catch (e) {
        // If user data is corrupted, clear it
        await TokenStorage.clearAll();
      }
    }
  }

  // Real login with API integration
  static Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.login(
        username: username,
        password: password,
      );

      if (response['success'] == true) {
        final data = response['data'];
        
        // Store token
        await TokenStorage.saveToken(
          data['access_token'],
          data['token_type'],
        );

        // Store user data (you might want to fetch user profile separately)
        _currentUser = {
          'username': username,
          'token_validity': data['token_validity'],
        };
        await TokenStorage.saveUserData(jsonEncode(_currentUser));

        return true;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow; // Don't fall back to mock login, throw the actual error
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Call logout API to invalidate token on server
      await ApiService.logout();
    } catch (e) {
      // Even if API call fails, we should still clear local data
      // This ensures user is logged out locally even if server is unreachable
      print('Logout API failed: $e');
    } finally {
      // Always clear local storage regardless of API response
      await TokenStorage.clearAll();
      _currentUser = null;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true) {
        // Update current user data
        _currentUser = response['data'];
        await TokenStorage.saveUserData(jsonEncode(_currentUser));
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String contact,
    String? email,
    String? password,
  }) async {
    return await ApiService.register(
      name: name,
      contact: contact,
      email: email,
      password: password,
    );
  }

  // Delete/Deactivate account
  static Future<void> deleteAccount() async {
    try {
      // Call delete account API
      await ApiService.deleteAccount();
      
      // Only clear local storage after successful API call
      await TokenStorage.clearAll();
      _currentUser = null;
    } catch (e) {
      // Don't clear local data if API call fails
      print('Delete account API failed: $e');
      rethrow; // Re-throw to show error to user
    }
  }
} 