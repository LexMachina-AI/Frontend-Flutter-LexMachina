import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class GeminiService {
  late GenerativeModel _model;
  late ChatSession chatSession;

  Future<void> initialize() async {
    final apiKey = dotenv.dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system('You are LexMachina...'), // Your system prompt
    );
    
    chatSession = _model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    final content = Content.text(message);
    final response = await chatSession.sendMessage(content);
    return response.text;
  }
}