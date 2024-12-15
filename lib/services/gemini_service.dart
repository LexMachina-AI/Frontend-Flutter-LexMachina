import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // Dart HTTP client
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class GeminiService {
  late String backendUrl;

  // Initializes the service by loading the backend URL and validating it
  Future<void> initialize() async {
    // Load backend URL from environment variables
    backendUrl = dotenv.dotenv.env['BACKEND_URL'] ??
        '';

    if (backendUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    if (kDebugMode) {
      print('Loaded backend URL: $backendUrl');
    }

    // Perform a health check to ensure the backend is reachable
    try {
      final response = await http.get(Uri.parse('$backendUrl/'));
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Backend initialization successful: ${response.body}');
        }
      } else {
        throw Exception('Backend health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to initialize backend: $e');
    }
  }

  // Maintains the chat session history in memory
  List<Map<String, String>> conversationHistory = [];

  // Sends a message to the backend and retrieves the response
  Future<String?> sendMessage(String question) async {
    if (question.isEmpty) {
      throw Exception('Question cannot be empty.');
    }

    // Construct the payload for the backend request
    final requestBody = jsonEncode({"question": question});

    try {
      // Send POST request to the backend API
      final response = await http.post(
        Uri.parse('$backendUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Handle backend response
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Check if the response has an error
        if (responseBody.containsKey('error')) {
          throw Exception('Backend Error: ${responseBody['error']}');
        }

        // Extract and save the AI response
        final backendResponse = responseBody['response'] as String;

        if (kDebugMode) {
          print("Backend Raw Response:\n$backendResponse");
        }

        final parser = BackendResponseParser();
        try {
          final aiResponse = parser.parseResponse(response.body);
          
          if (kDebugMode) {
            print("Parsed Response:\n$aiResponse");
          }
          conversationHistory.add({'user': question, 'ai': aiResponse});
          return aiResponse;
        } catch (e) {
          if (kDebugMode) {
            print("Error: $e");
          }
          return null;
        }

        
      } else {
        throw Exception(
            'Failed to fetch response from backend: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions like network errors
      throw Exception('Error communicating with backend: $e');
    }
  }
}

class BackendResponseParser {
  // Parses the JSON response from the backend
  String parseResponse(String backendResponse) {
    try {
      final jsonData = jsonDecode(backendResponse);

      if (!jsonData.containsKey('response')) {
        throw Exception('Invalid JSON format: Missing response field');
      }

      if (!jsonData.containsKey('status')) {
        throw Exception('Invalid JSON format: Missing status field');
      }

      if (jsonData['status'] != 'success') {
        throw Exception('Backend error: ${jsonData['response']}');
      }      
      return jsonData['response'];
    } catch (e) {
      throw Exception('Error parsing JSON response: $e');
    }
  }
}
