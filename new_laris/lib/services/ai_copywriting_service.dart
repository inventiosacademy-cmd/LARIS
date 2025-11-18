import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiCopywritingService {
  AiCopywritingService({
    http.Client? client,
    String? apiKey,
    String? model,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _apiKey = _resolveApiKey(apiKey),
        _model = (model ?? 'gemini-2.5-flash').trim(),
        _timeout = timeout ?? _defaultTimeout;

  static const Duration _defaultTimeout = Duration(seconds: 45);
  static const String _defaultApiKey =
      'AIzaSyBUHyD25IR3hjkUwreTeSgAJs1J_D1nJIg';

  final http.Client _client;
  final String _apiKey;
  final String _model;
  final Duration _timeout;

  Uri get _endpoint => Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/$_model:generateContent',
        {'key': _apiKey},
      );

  Future<String> generateCopywriting(String prompt) async {
    final sanitized = prompt.trim();
    if (sanitized.isEmpty) {
      throw const AiCopywritingServiceException(
        'Prompt copywriting tidak boleh kosong.',
      );
    }

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': sanitized},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.9,
        'topP': 0.95,
        'topK': 40,
      },
    };

    final response = await _client
        .post(
          _endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    if (response.statusCode >= 400) {
      throw AiCopywritingServiceException(_extractErrorMessage(response));
    }

    final text = _firstCandidateText(_tryDecodeJson(response));
    if (text == null || text.trim().isEmpty) {
      throw const AiCopywritingServiceException(
        'Gemini tidak mengembalikan copywriting.',
      );
    }
    return text.trim();
  }

  dynamic _tryDecodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  String? _firstCandidateText(dynamic parsed) {
    if (parsed is Map) {
      final candidates = parsed['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final first = candidates.first;
        if (first is Map) {
          final content = first['content'];
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final buffer = StringBuffer();
              for (final part in parts) {
                if (part is Map) {
                  final text = part['text'];
                  if (text is String) {
                    buffer.write(text);
                  }
                }
              }
              final combined = buffer.toString().trim();
              if (combined.isNotEmpty) {
                return combined;
              }
            }
          }
        }
      }
    }
    return null;
  }

  String _extractErrorMessage(http.Response response) {
    final parsed = _tryDecodeJson(response);
    if (parsed is Map) {
      final error = parsed['error'];
      if (error is Map) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'API key Gemini tidak valid untuk copywriting.';
    }
    if (response.statusCode == 429) {
      return 'Permintaan ke Gemini terlalu sering. Coba sebentar lagi.';
    }

    return 'Gagal meminta copywriting (kode ${response.statusCode}).';
  }

  static String _resolveApiKey(String? provided) {
    final candidate =
        (provided?.trim().isNotEmpty ?? false) ? provided!.trim() : '';
    if (candidate.isNotEmpty) {
      return candidate;
    }
    if (_defaultApiKey.isEmpty) {
      throw const AiCopywritingServiceException(
        'API key Gemini tidak ditentukan.',
      );
    }
    return _defaultApiKey;
  }

  void dispose() {
    _client.close();
  }
}

class AiCopywritingServiceException implements Exception {
  const AiCopywritingServiceException(this.message);

  final String message;

  @override
  String toString() => 'AiCopywritingServiceException: $message';
}
