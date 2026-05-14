import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Base URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await SecureStorage().getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      // Convert all query param values to strings for Uri compatibility
      final stringParams = queryParams?.map(
        (key, value) => MapEntry(key, value?.toString()),
      );

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: stringParams);

      if (kDebugMode) {
        print('🌐 GET Request: $uri');
      }

      final response = await http.get(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        print('🌐 POST Request: $uri');
        print('📦 Data: $data');
      }

      final response = await http.post(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: data != null ? jsonEncode(data) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        print('🌐 PUT Request: $uri');
        print('📦 Data: $data');
      }

      final response = await http.put(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: data != null ? jsonEncode(data) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST multipart/form-data request (for file uploads)
  Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<File>? files,
    String fileFieldName = 'images',
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        print('🌐 POST Multipart Request: $uri');
        print('📦 Fields: $fields');
        print('📦 Files: ${files?.map((f) => f.path).toList()}');
      }

      final request = http.MultipartRequest('POST', uri);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      // MultipartRequest sets its own Content-Type header; remove JSON header
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (fields != null) request.fields.addAll(fields);

      if (files != null) {
        for (var file in files) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            fileFieldName,
            stream,
            length,
            filename: path.basename(file.path),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        print('🌐 DELETE Request: $uri');
      }

      final response = await http.delete(
        uri,
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
    }

    // Try to parse error message if available
    String getErrorMessage() {
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error.containsKey('detail')) {
          return error['detail'].toString();
        }
        if (error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
      } catch (_) {}
      return 'Request failed with status ${response.statusCode}';
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 204:
        return null;
      case 400:
        throw ApiException(getErrorMessage(), 400);
      case 401:
        throw ApiException('Invalid email or password', 401);
      case 403:
        throw ApiException('Access denied', 403);
      case 404:
        throw ApiException('Resource not found', 404);
      case 422:
        throw ApiException('Validation error', 422);
      case 500:
        throw ApiException('Server error. Please try again later', 500);
      default:
        throw ApiException(getErrorMessage(), response.statusCode);
    }
  }

  // Handle error
  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;

    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      return ApiException(
        'Unable to connect to server. Check your internet connection.',
        0,
      );
    }

    return ApiException('An unexpected error occurred', 0);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
