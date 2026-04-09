import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterService {
  // 1. Paste your OpenRouter API Key here
  static final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // 2. The exact model tag for Gemma 3 27B on OpenRouter
  static const String _model = 'openrouter/free';

  Future<String> generateResponse(String prompt, String mode) async {
    String systemPrompt = _getSystemPromptForMode(mode);

    // OpenRouter's universal endpoint
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        // OpenRouter requests these optional headers for analytics,
        // you can put your app's name here!
        'HTTP-Referer': 'https://github.com/your-username',
        'X-Title': 'Knowledge Tracker Companion',
      },
      body: jsonEncode({
        "model": _model,
        "messages": [
          // The System role sets the behavior of the AI
          {"role": "system", "content": systemPrompt},
          // The User role is the actual prompt
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // OpenRouter returns data in the standard OpenAI format
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenRouter Error: ${response.statusCode}\nBody: ${response.body}');
    }
  }

  // Pass BOTH subject and topic into the method
  Future<String> generateQuizQuestion(String subject, String topic) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": _model,
        "messages": [
          {
            "role": "system",
            "content": "You are a quiz generator. Output ONLY a single line formatted exactly like this: Question|Option0|Option1|Option2|Option3|CorrectIndex(0-3). No intro, no outro, no markdown."
          },
          {
            "role": "user",
            // Update the prompt to provide the full context
            "content": "Generate 1 intermediate multiple-choice question about the specific topic of '$topic' within the broader subject of '$subject'."
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to generate quiz.');
    }
  }

  String _getSystemPromptForMode(String mode) {
    switch (mode) {
      case 'Tutor':
        return 'You are an expert tutor. Explain concepts clearly, break down complex topics, and use analogies.';
      case 'Mock Interviewer':
        return 'You are a strict technical interviewer. Ask challenging questions one by one and evaluate the user\'s response.';
      case 'Evaluator':
        return 'You are a diagnostic evaluator. Assess the user\'s answer for accuracy and provide a confidence score from 1-100.';
      case 'Motivator':
      default:
        return 'You are an encouraging mentor. Keep responses brief, positive, and focus on building learning habits.';
    }
  }
}