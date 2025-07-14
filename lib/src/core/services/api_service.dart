import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config.dart';
import 'token_storage.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseDomain;
  
  // Callback for session expiration
  static void Function()? onSessionExpired;
  
  static Future<Map<String, String>> get _headers async {
    final baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization header if token exists
    final authHeader = await TokenStorage.getAuthHeader();
    if (authHeader != null) {
      baseHeaders['Authorization'] = authHeader;
    }

    return baseHeaders;
  }

  // Generic POST request method
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _headers;
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  // Generic GET request method
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _headers;
      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  // Generic DELETE request method
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = await _headers;
      final response = await http.delete(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else if (response.statusCode == 401) {
        // Session expired - handle logout
        _handleSessionExpired();
        throw Exception('Session expired. Please login again.');
      } else {
        // Handle error responses
        String errorMessage = 'Request failed (${response.statusCode})';
        
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors')) {
          // Handle validation errors
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.cast<String>());
            } else {
              errorList.add(value.toString());
            }
          });
          errorMessage = errorList.join(', ');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // If JSON parsing fails, return the raw response
      throw Exception('Invalid response format: ${response.body}');
    }
  }

  // Handle session expiration
  static Future<void> _handleSessionExpired() async {
    // Clear local storage
    await TokenStorage.clearAll();
    
    // Call the callback if set
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  // Signup/Registration API call
  static Future<Map<String, dynamic>> register({
    required String name,
    required String contact,
    String? email,
    String? password,
    String? province,
    String? districtCity,
    String? guardianName,
    String? guardianContact,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'contact': contact,
    };

    // Add optional fields if provided
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (province != null && province.isNotEmpty) data['provience'] = province;
    if (districtCity != null && districtCity.isNotEmpty) data['district_city'] = districtCity;
    if (guardianName != null && guardianName.isNotEmpty) data['guardian_name'] = guardianName;
    if (guardianContact != null && guardianContact.isNotEmpty) data['guardian_contact'] = guardianContact;

    return await post('api/register', data);
  }

  // Login API call
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final data = {
      'username': username,
      'password': password,
    };

    return await post('api/login', data);
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await get('api/profile');
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    return await post('api/logout', {});
  }

  // Delete/Deactivate account
  static Future<Map<String, dynamic>> deleteAccount() async {
    return await delete('api/account/deactivate');
  }

  // Get privacy policy content
  static Future<Map<String, dynamic>> getPrivacyPolicy() async {
    return await get('api/privacy');
  }

  static Future<Map<String, dynamic>> getCourseClassroom() async {
    try {
      final authHeader = await TokenStorage.getAuthHeader();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/student/course/classroom'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load course classroom data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Chat-related API methods
  static Future<Map<String, dynamic>> getChatMessages(int batchId, {int page = 1}) async {
    return await get('api/student/course/classroom/$batchId/chat?page=$page');
  }

  static Future<Map<String, dynamic>> sendChatMessage(int batchId, String message) async {
    return await post('api/student/course/classroom/$batchId/chat', {
      'message': message,
    });
  }

  static Future<Map<String, dynamic>> getChatInfo(int batchId) async {
    return await get('api/student/course/classroom/$batchId/chat/info');
  }

  // Notification-related API methods
  static Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    return await get('api/student/notifications?page=$page');
  }

  static Future<Map<String, dynamic>> getNotificationDetail(int notificationId) async {
    return await get('api/student/notifications/$notificationId');
  }

  // Orientation-related API methods
  static Future<Map<String, dynamic>> getOrientations() async {
    return await get('api/student/course/orientations');
  }

  static Future<Map<String, dynamic>> joinOrientation(String joinUrl) async {
    // Extract the endpoint from the full URL
    final uri = Uri.parse(joinUrl);
    final endpoint = uri.path.substring(1); // Remove leading slash
    
    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> getFromFullUrl(String fullUrl) async {
    final uri = Uri.parse(fullUrl);
    final headers = await _headers;
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> postToFullUrl(String fullUrl, Map<String, dynamic> data) async {
    final uri = Uri.parse(fullUrl);
    final headers = await _headers;
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteFromFullUrl(String fullUrl) async {
    final uri = Uri.parse(fullUrl);
    final headers = await _headers;
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  // Profile update methods
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? contact,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (contact != null) data['contact'] = contact;
    if (email != null) data['email'] = email;
    
    return await post('api/profile/update', data);
  }

  // Update profile with image
  static Future<Map<String, dynamic>> updateProfileWithImage({
    String? name,
    String? contact,
    String? email,
    String? imagePath,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/profile/update');
      final request = http.MultipartRequest('POST', url);
      
      // Add headers
      final authHeader = await TokenStorage.getAuthHeader();
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }
      request.headers['Accept'] = 'application/json';
      
      // Add fields
      if (name != null) request.fields['name'] = name;
      if (contact != null) request.fields['contact'] = contact;
      if (email != null) request.fields['email'] = email;
      
      // Add image file if provided
      if (imagePath != null) {
        final file = await http.MultipartFile.fromPath('photo', imagePath);
        request.files.add(file);
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      return _handleMultipartResponse(response.statusCode, responseBody);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Handle multipart response
  static Map<String, dynamic> _handleMultipartResponse(int statusCode, String responseBody) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        return responseData;
      } else if (statusCode == 401) {
        // Session expired - handle logout
        _handleSessionExpired();
        throw Exception('Session expired. Please login again.');
      } else {
        // Handle error responses
        String errorMessage = 'Request failed ($statusCode)';
        
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors')) {
          // Handle validation errors
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.cast<String>());
            } else {
              errorList.add(value.toString());
            }
          });
          errorMessage = errorList.join(', ');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // If JSON parsing fails, return the raw response
      throw Exception('Invalid response format: $responseBody');
    }
  }

  // Booking-related API methods
  static Future<Map<String, dynamic>> getUserBookings() async {
    return await get('api/student/course/bookings');
  }
} 