import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

/// Menyediakan layanan untuk membuat logo berbasis prompt Gemini.
class AiLogoService {
  AiLogoService({
    http.Client? client,
    String? apiKey,
    String? model,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _apiKey = _resolveApiKey(apiKey),
        _model = (model ?? 'gemini-2.5-flash-image').trim(),
        _timeout = timeout ?? _defaultTimeout;

  static const Duration _defaultTimeout = Duration(minutes: 2);
  static const String _defaultApiKey =
      'AIzaSyACZ_Q3WAShC9X0lhgVcUlZw_GoNyVdEpA';

  final http.Client _client;
  final String _apiKey;
  final String _model;
  final Duration _timeout;

  Uri get _endpoint => Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/$_model:generateContent',
        {'key': _apiKey},
      );

  /// Menghasilkan logo dalam bentuk byte array berdasarkan parameter yang diberikan.
  Future<AiLogoResult> generateLogo({
    String? productName,
    String? productType,
    String? primaryColor,
    String? mascotPreference,
    String? tagline,
  }) async {
    final prompt = _composePrompt(
      productName: productName,
      productType: productType,
      primaryColor: primaryColor,
      mascotPreference: mascotPreference,
      tagline: tagline,
    );

    if (prompt.isEmpty) {
      throw const AiLogoServiceException('Prompt logo tidak boleh kosong.');
    }

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.8,
        'topP': 0.9,
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
      throw AiLogoServiceException(_extractErrorMessage(response));
    }

    final parsed = _tryDecodeJson(response);
    if (parsed == null) {
      throw const AiLogoServiceException(
        'Gemini tidak mengembalikan respons logo yang valid.',
      );
    }

    final inline = _firstInlineData(parsed);
    if (inline != null) {
      return AiLogoResult(
        bytes: inline.bytes,
        mimeType: inline.mimeType,
        prompt: prompt,
      );
    }

    final fallback = _firstCandidateText(parsed);
    if (fallback != null && fallback.isNotEmpty) {
      throw AiLogoServiceException(fallback);
    }

    throw const AiLogoServiceException('Gemini tidak mengembalikan data logo.');
  }

  Future<String> downloadLogo(
    Uint8List bytes, {
    String? fileName,
  }) async {
    final resolvedName = _sanitizeFileName(
      fileName?.trim().isNotEmpty == true
          ? fileName!.trim()
          : 'laris_ai_logo_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    if (kIsWeb) {
      final anchor = html.AnchorElement()
        ..href = 'data:application/octet-stream;base64,${base64Encode(bytes)}'
        ..download = resolvedName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      return resolvedName;
    }

    final directory = await _resolveDownloadDirectory();
    final targetPath =
        '${directory.path}${io.Platform.pathSeparator}$resolvedName';
    final file = io.File(targetPath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _composePrompt({
    String? productName,
    String? productType,
    String? primaryColor,
    String? mascotPreference,
    String? tagline,
  }) {
    String normalized(String? value) => value?.trim() ?? '';
    String mascotLine() {
      final trimmed = mascotPreference?.trim() ?? '';
      final lower = trimmed.toLowerCase();
      const yesValues = {'iya', 'ya', 'yes', 'y', 'true'};
      const noValues = {'tidak', 'ga', 'gak', 'enggak', 'no', 'n', 'false'};
      if (lower.isEmpty) {
        return '4. tambahkan maskot yang sesuai dengan produk';
      }
      if (yesValues.contains(lower)) {
        return '4. tambahkan maskot yang sesuai dengan produk';
      }
      if (noValues.contains(lower)) {
        return '4. tidak usah tambahkan maskot yang sesuai dengan produk';
      }
      return '4. tambahkan maskot yang sesuai dengan produk : $trimmed';
    }

    final buffer = StringBuffer('Buatkan logo dengan beberapa aspek berikut:\n')
      ..writeln('1. nama produk / jasa adalah : ${normalized(productName)}')
      ..writeln('2. produk berupa : ${normalized(productType)}')
      ..writeln('3. warna : ${normalized(primaryColor)}')
      ..writeln(mascotLine())
      ..writeln('5. tagline : ${normalized(tagline)}')
      ..writeln('6. latar belakang putih')
      ..writeln('7. jangan ada glitch, typo, blur , khayal')
      ..writeln('8. output berupa gambar bukan tulisan');

    return buffer.toString().trim();
  }

  dynamic _tryDecodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  _InlineLogoData? _firstInlineData(dynamic parsed) {
    if (parsed is Map) {
      final candidates = parsed['candidates'];
      if (candidates is List) {
        for (final candidate in candidates) {
          if (candidate is Map) {
            final content = candidate['content'];
            if (content is Map) {
              final parts = content['parts'];
              if (parts is List) {
                for (final part in parts) {
                  if (part is Map) {
                    final inline = part['inlineData'] ?? part['inline_data'];
                    if (inline is Map) {
                      final data = inline['data'];
                      final mimeType = inline['mimeType'] ??
                          inline['mime_type'] ??
                          'image/png';
                      if (data is String && data.isNotEmpty) {
                        try {
                          return _InlineLogoData(
                            bytes: base64Decode(data),
                            mimeType: mimeType,
                          );
                        } catch (_) {
                          continue;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  String? _firstCandidateText(dynamic parsed) {
    if (parsed is Map) {
      final candidates = parsed['candidates'];
      if (candidates is List) {
        for (final candidate in candidates) {
          if (candidate is Map) {
            final content = candidate['content'];
            if (content is Map) {
              final parts = content['parts'];
              if (parts is List) {
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

      final text = _firstCandidateText(parsed);
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'API key Gemini tidak valid untuk logo.';
    }
    if (response.statusCode == 429) {
      return 'Permintaan pembuatan logo terlalu sering. Coba lagi nanti.';
    }

    return 'Gagal membuat logo (kode ${response.statusCode}).';
  }

  static String _resolveApiKey(String? provided) {
    final candidate =
        (provided?.trim().isNotEmpty ?? false) ? provided!.trim() : '';
    if (candidate.isNotEmpty) {
      return candidate;
    }
    if (_defaultApiKey.isEmpty) {
      throw const AiLogoServiceException(
        'API key Gemini tidak disediakan untuk logo.',
      );
    }
    return _defaultApiKey;
  }

  Future<io.Directory> _resolveDownloadDirectory() async {
    if (!kIsWeb && io.Platform.isAndroid) {
      const manualPaths = [
        '/storage/self/primary/Download',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/Download',
        '/sdcard/Download',
      ];
      for (final path in manualPaths) {
        final dir = io.Directory(path);
        if (await dir.exists()) {
          return dir;
        }
        try {
          await dir.create(recursive: true);
          if (await dir.exists()) {
            return dir;
          }
        } catch (_) {
          // ignore and continue
        }
      }
      try {
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          return io.Directory(externalDirs.first.path);
        }
      } catch (_) {
        // ignore and fallback later
      }
    }

    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        return io.Directory(downloads.path);
      }
    } catch (_) {
      // ignore and fallback
    }

    final documents = await getApplicationDocumentsDirectory();
    return io.Directory(documents.path);
  }

  String _sanitizeFileName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'laris_ai_logo.png' : sanitized;
  }

  void dispose() {
    _client.close();
  }
}

class AiLogoResult {
  const AiLogoResult({
    required this.bytes,
    required this.mimeType,
    required this.prompt,
  });

  final Uint8List bytes;
  final String mimeType;
  final String prompt;

  String get suggestedExtension {
    switch (mimeType) {
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/webp':
        return 'webp';
      default:
        return 'png';
    }
  }
}

class AiLogoServiceException implements Exception {
  const AiLogoServiceException(this.message);

  final String message;

  @override
  String toString() => 'AiLogoServiceException: $message';
}

class _InlineLogoData {
  const _InlineLogoData({
    required this.bytes,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String mimeType;
}
