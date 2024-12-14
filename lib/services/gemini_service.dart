import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // Dart HTTP client
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class GeminiService {
  late String backendUrl;

  // Initializes the service by loading the backend URL and validating it
  Future<void> initialize() async {
    // Load backend URL from environment variables
    backendUrl = dotenv.dotenv.env['BACKEND_URL'] ??
        'https://codespaces-flask-916007394186.asia-south1.run.app';

    if (backendUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    print('Loaded backend URL: $backendUrl');

    // Perform a health check to ensure the backend is reachable
    try {
      final response = await http.get(Uri.parse('$backendUrl/'));
      if (response.statusCode == 200) {
        print('Backend initialization successful: ${response.body}');
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
        final aiResponse = responseBody['response'] as String;
        conversationHistory.add({'user': question, 'ai': aiResponse});
        return aiResponse;
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
