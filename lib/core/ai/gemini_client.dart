import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Minimal Gemini REST client. The key comes from the build, never the code:
/// `flutter run --dart-define=GEMINI_API_KEY=...`
class GeminiClient {
  GeminiClient({http.Client? httpClient, String? apiKey, String? model})
      : _http = httpClient ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
        _model = model ??
            const String.fromEnvironment(
              'GEMINI_MODEL',
              defaultValue: 'gemini-2.5-flash',
            );

  final http.Client _http;
  final String _apiKey;
  final String _model;

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Sends a prompt (and optional JPEG) and returns the JSON the model wrote.
  Future<Map<String, dynamic>> generateJson(
    String prompt, {
    Uint8List? image,
  }) async {
    if (!isConfigured) {
      throw const GeminiException('GEMINI_API_KEY belum diisi saat build.');
    }
    final response = await _http
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
          ),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  if (image != null)
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Encode(image),
                      },
                    },
                ],
              },
            ],
            'generationConfig': {'responseMimeType': 'application/json'},
          }),
        )
        .timeout(const Duration(seconds: 60));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      throw GeminiException(
        error?['message'] as String? ?? 'Gemini error ${response.statusCode}',
      );
    }

    final candidates = body['candidates'] as List<dynamic>? ?? const [];
    if (candidates.isEmpty) {
      throw const GeminiException('Gemini tidak mengembalikan jawaban.');
    }
    final content = (candidates.first as Map<String, dynamic>)['content']
        as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final text = (parts.first as Map<String, dynamic>)['text'] as String;
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
