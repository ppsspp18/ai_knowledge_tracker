import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // STREAMING CHAT GENERATOR
  Future<void> generateStreamResponse({
    required String prompt,
    required String mode,
    required String endpoint,
    required String apiKey,
    required String model,
    required Function(String) onChunk,
    required Function(String) onError,
    required Function() onDone,
  }) async {
    final systemPrompt = _getSystemPromptForMode(mode);

    // Clean URL to prevent hidden spaces from causing SocketExceptions
    final url = Uri.parse(endpoint.trim());
    final client = http.Client();

    try {
      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        // Trim key to ensure no hidden line breaks break the Auth header
        'Authorization': 'Bearer ${apiKey.trim()}',
        'User-Agent': 'PostmanRuntime/7.36.1', // ADD THIS LINE
        'Accept': '*/*',                       // ADD THIS LINE
      });

      request.body = jsonEncode({
        "model": model.trim(),
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": prompt}
        ],
        "stream": true
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final errBody = await response.stream.bytesToString();
        onError('API Error (${response.statusCode}): $errBody');
        return;
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
          // Robust whitespace handling for JSON chunks
          final cleanLine = line.trim();
          if (cleanLine.isEmpty) return;

          try {
            if (cleanLine.startsWith('data: ')) {
              final dataStr = cleanLine.substring(6).trim();
              if (dataStr == '[DONE]') return;
              final data = jsonDecode(dataStr);
              if (data['choices'] != null && data['choices'].isNotEmpty) {
                final delta = data['choices'][0]['delta'];
                if (delta['content'] != null) onChunk(delta['content']);
              }
            }
            else if (cleanLine.startsWith('{')) {
              final data = jsonDecode(cleanLine);
              // Handle Ollama Format
              if (data['message'] != null && data['message']['content'] != null) {
                onChunk(data['message']['content']);
              }
              // Handle OpenAI Compatible Format
              else if (data['choices'] != null && data['choices'].isNotEmpty) {
                final msg = data['choices'][0]['message'] ?? data['choices'][0]['delta'];
                if (msg != null && msg['content'] != null) onChunk(msg['content']);
              }
            }
          } catch (e) {
            // Ignore malformed text chunks and continue the stream
          }
        },
        onDone: onDone,
        onError: (e) => onError('Stream Error: $e'),
      );
    } catch (e) {
      onError('Network Error: $e');
    }
  }

  // NON-STREAMING QUIZ GENERATOR
  Future<String> generateQuizQuestion({
    required String subject,
    required String topic,
    required String endpoint,
    required String apiKey,
    required String model,
  }) async {
    //final url = Uri.parse(endpoint.trim());
    final url = Uri.parse('https://api.exact-url-from-postman.com/api/chat');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
        'User-Agent': 'PostmanRuntime/7.36.1', // ADD THIS LINE
        'Accept': '*/*',                       // ADD THIS LINE
      },
      body: jsonEncode({
        "model": model.trim(),
        "stream": false,
        "messages": [
          {
            "role": "system",
            "content": "You are a rigid quiz generator. You MUST output ONLY ONE line of text formatted exactly like this: Question|Option0|Option1|Option2|Option3|CorrectIndex(0-3). Do NOT include introductions, explanations, or markdown blocks."
          },
          {
            "role": "user",
            "content": "Generate 1 multiple-choice question about '$topic' in '$subject'."
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String rawOutput = "";

      // Parse whichever format the API returns
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        rawOutput = data['choices'][0]['message']['content'];
      } else if (data['message'] != null) {
        rawOutput = data['message']['content'];
      }

      // BULLETPROOF PARSER: Even if the AI gets chatty, this finds the quiz line
      final lines = rawOutput.split('\n');
      for (var line in lines) {
        // A valid quiz line will split into exactly 6 pieces based on the '|' character
        if (line.split('|').length == 6) {
          return line.trim();
        }
      }

      throw Exception('AI did not format the quiz properly. Output was: $rawOutput');
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  String _getSystemPromptForMode(String mode) {
    switch (mode) {
      case 'Tutor': return 'You are an expert tutor. Explain concepts clearly, break down complex topics, and use analogies.';
      case 'Mock Interviewer': return 'You are a strict technical interviewer. Ask challenging questions one by one and evaluate the user\'s response.';
      case 'Evaluator': return 'You are a diagnostic evaluator. Assess the user\'s answer for accuracy and provide a confidence score from 1-100.';
      case 'Motivator': default: return 'You are an encouraging mentor. Keep responses brief, positive, and focus on building learning habits.';
    }
  }
}