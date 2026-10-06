import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sirkular/core/ai/gemini_client.dart';

void main() {
  test('sends the key in a header and returns the JSON reply', () async {
    late http.Request sent;
    final client = GeminiClient(
      apiKey: 'test-key',
      model: 'gemini-test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '{"name":"Tepung","stock":5}'},
                  ],
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    final json = await client.generateJson('halo');

    expect(json['name'], 'Tepung');
    expect(sent.headers['x-goog-api-key'], 'test-key');
    expect(sent.url.path, contains('gemini-test:generateContent'));
    expect(sent.url.toString(), isNot(contains('test-key')));
  });

  test('surfaces the API error message', () async {
    final client = GeminiClient(
      apiKey: 'bad',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'message': 'API key not valid'}
          }),
          400,
        ),
      ),
    );

    await expectLater(
      client.generateJson('halo'),
      throwsA(isA<GeminiException>()
          .having((e) => e.message, 'message', 'API key not valid')),
    );
  });

  test('without a key nothing is sent', () async {
    final client = GeminiClient(
        apiKey: '',
        httpClient: MockClient((_) async => throw StateError('no call')));
    expect(client.isConfigured, isFalse);
    await expectLater(
        client.generateJson('halo'), throwsA(isA<GeminiException>()));
  });
}
