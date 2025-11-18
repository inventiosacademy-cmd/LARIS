import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

/// Menggunakan Gemini API untuk mempercantik foto produk dan mengunduh hasilnya.
class AiImageService {
  AiImageService({
    http.Client? client,
    String? apiKey,
    String? model,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _apiKey = _resolveApiKey(apiKey),
        _model = _resolveModel(model),
        _timeout = timeout ?? _defaultTimeout;

  static const Duration _defaultTimeout = Duration(minutes: 2);
  static const String _defaultApiKey =
      'AIzaSyCJ-kkvkSoDEBYQrwErfiQTdm1DK3_sgXA';
  static const String _defaultPrompt = '''
Tingkatkan kualitas visual foto produk e-commerce berikut :
1. Pertahankan bentuk produk jangan merubah apapun yang ada dalam produk seperti bentuk , warna, merk, dan lainnya 
2. Ubah latar belakang menjadi foto katalog profesional dalam studio, sesuaikan tema latar dengan foto produknya
3. Pencahayaan terang, tulisan dipertahankan, tajam, tidak blur, FHD
4.jika ada tangan yang memegang produk, hilangkan tangan tersebut
5. Jangan menambahkan elemen lain selain produk itu sendiri
6. Hasil akhir dalam format gambar berkualitas tinggi
''';

  final http.Client _client;
  final String _apiKey;
  final String _model;
  final Duration _timeout;

  Uri get _endpoint => Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/$_model:generateContent',
        {'key': _apiKey},
      );

  Future<AiImageResult> enhanceProductImage(
    Uint8List imageBytes, {
    String? instructions,
    AiImageTuning tuning = const AiImageTuning(),
    String? mimeType,
  }) async {
    if (imageBytes.isEmpty) {
      throw const AiImageServiceException('Image bytes tidak boleh kosong.');
    }

    final resolvedMime =
        mimeType ?? lookupMimeType('', headerBytes: imageBytes) ?? 'image/png';
    final prompt = _resolvePrompt(instructions);
    final payload = _buildRequestPayload(
      prompt: '${prompt.trim()} ${tuning.descriptor}'.trim(),
      mimeType: resolvedMime,
      imageBytes: imageBytes,
    );

    final response = await _sendRequest(payload);
    if (response.statusCode >= 400) {
      throw AiImageServiceException(_extractErrorMessage(response));
    }
    final parsed = _tryDecodeJson(response);
    if (parsed == null) {
      throw const AiImageServiceException(
        'Gemini tidak mengembalikan respons yang valid.',
      );
    }

    final inline = _firstInlineData(parsed);
    if (inline != null) {
      return AiImageResult(
        bytes: inline,
        mimeType: resolvedMime,
        prompt: prompt,
      );
    }

    final fallback = _firstCandidateText(parsed);
    if (fallback != null && fallback.isNotEmpty) {
      throw AiImageServiceException(fallback);
    }

    throw const AiImageServiceException('Gemini tidak mengembalikan data gambar.');
  }

  Future<String> downloadImage(
    Uint8List bytes, {
    String? fileName,
  }) async {
    final resolvedName = _sanitizeFileName(
      fileName ??
          'laris_ai_image_${kIsWeb ? 'web' : 'device'}_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    if (kIsWeb) {
      final base64Data = base64Encode(bytes);
      final anchor = html.AnchorElement()
        ..href = 'data:application/octet-stream;base64,$base64Data'
        ..download = resolvedName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      return resolvedName;
    }

    final targetDir = await _resolveDownloadDirectory();
    final file = io.File('${targetDir.path}${io.Platform.pathSeparator}$resolvedName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<http.Response> _sendRequest(Map<String, Object?> payload) async {
    try {
      return await _client
          .post(
            _endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw AiImageServiceException(
        'Permintaan ke Gemini melebihi batas waktu ${_timeout.inSeconds} detik.',
      );
    } on http.ClientException catch (error) {
      throw AiImageServiceException(
        'Gagal terhubung ke layanan Gemini: ${error.message}',
      );
    } catch (error) {
      throw AiImageServiceException('Gagal mengirim permintaan: $error');
    }
  }

  Map<String, Object?> _buildRequestPayload({
    required String prompt,
    required String mimeType,
    required Uint8List imageBytes,
  }) {
    return {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
    };
  }

  Map<String, dynamic>? _tryDecodeJson(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  Uint8List? _firstInlineData(Map<String, dynamic> json) {
    final candidates = json['candidates'];
    if (candidates is! List) return null;
    for (final candidate in candidates) {
      if (candidate is! Map) continue;
      final content = candidate['content'];
      final bytes = _bytesFromContent(content);
      if (bytes != null) {
        return bytes;
      }
    }
    return null;
  }

  Uint8List? _bytesFromContent(Object? content) {
    if (content is Map) {
      return _bytesFromParts(content['parts']);
    }
    if (content is List) {
      return _bytesFromParts(content);
    }
    return null;
  }

  Uint8List? _bytesFromParts(Object? parts) {
    if (parts is! List) return null;
    for (final part in parts) {
      if (part is! Map) continue;
      final inlineData = part['inline_data'] ?? part['inlineData'];
      if (inlineData is Map) {
        final data = inlineData['data'];
        if (data is String && data.isNotEmpty) {
          try {
            return base64Decode(data);
          } catch (_) {
            continue;
          }
        }
      }
      final fileData = part['file_data'] ?? part['fileData'];
      if (fileData is Map) {
        final uri = fileData['file_uri'] ?? fileData['fileUri'];
        if (uri is String && uri.isNotEmpty) {
          throw AiImageServiceException(
            'Gemini mengembalikan referensi file ($uri). Ambil file tersebut dahulu.',
          );
        }
      }
    }
    return null;
  }

  String? _firstCandidateText(Map<String, dynamic> json) {
    final candidates = json['candidates'];
    if (candidates is! List) return null;
    for (final candidate in candidates) {
      if (candidate is! Map) continue;
      final text = _textFromContent(candidate['content']);
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
    }
    return null;
  }

  String? _textFromContent(Object? content) {
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
        return buffer.isEmpty ? null : buffer.toString();
      }
    } else if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map) {
          final text = part['text'];
          if (text is String) {
            buffer.write(text);
          }
        }
      }
      return buffer.isEmpty ? null : buffer.toString();
    }
    return null;
  }

  Future<io.Directory> _resolveDownloadDirectory() async {
    if (!kIsWeb && io.Platform.isAndroid) {
      final preferredPaths = <String>[
        '/storage/download',
        '/storage/Download',
        '/storage/dowload',
        '/storage/self/primary/Download',
        '/storage/emulated/0/Download',
        '/sdcard/Download',
        '/storage/emulated/0/Downloads',
      ];
      for (final path in preferredPaths) {
        final manual = io.Directory(path);
        if (await manual.exists()) {
          return manual;
        }
        try {
          await manual.create(recursive: true);
          if (await manual.exists()) {
            return manual;
          }
        } catch (_) {
          // ignore create errors and continue
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
        // ignore and try other strategies
      }
      final fallbackManuals = <String>[
        '/storage/download',
        '/storage/Download',
        '/storage/dowload',
        '/storage/self/primary/Download',
        '/storage/emulated/0/Download',
      ];
      for (final fallback in fallbackManuals) {
        final manualDownloads = io.Directory(fallback);
        if (await manualDownloads.exists()) {
          return manualDownloads;
        }
      }
    }

    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        return io.Directory(downloads.path);
      }
    } catch (_) {
      // ignore, use fallback
    }
    final documents = await getApplicationDocumentsDirectory();
    return io.Directory(documents.path);
  }

  static String _resolveApiKey(String? provided) {
    final envKey = const String.fromEnvironment('GEMINI_API_KEY');
    final candidate =
        (provided?.trim().isNotEmpty ?? false) ? provided!.trim() : envKey;
    if (candidate.isNotEmpty) {
      return candidate;
    }
    if (_defaultApiKey.isEmpty) {
      throw const AiImageServiceException(
        'Gemini API key belum dikonfigurasi. Setel GEMINI_API_KEY atau apiKey.',
      );
    }
    return _defaultApiKey;
  }

  static String _resolveModel(String? provided) {
    final envModel = const String.fromEnvironment(
      'GEMINI_IMAGE_MODEL',
      defaultValue: 'gemini-2.5-flash-image',
    );
    final candidate =
        (provided?.trim().isNotEmpty ?? false) ? provided!.trim() : envModel;
    final lower = candidate.toLowerCase();
    if (lower == 'nano banana' || lower == 'nano-banana') {
      return 'imagen-3.0-nano-banana';
    }
    return candidate;
  }

  String _resolvePrompt(String? prompt) {
    final sanitized = prompt?.trim();
    if (sanitized != null && sanitized.isNotEmpty) {
      return sanitized;
    }
    return _defaultPrompt.trim();
  }

  String _sanitizeFileName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'laris_ai_image.png' : sanitized;
  }

  String _extractErrorMessage(http.Response response) {
    final parsed = _tryDecodeJson(response);
    if (parsed != null) {
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
      final promptFeedback = parsed['promptFeedback'];
      if (promptFeedback is Map) {
        final reason =
            promptFeedback['blockReason'] ?? promptFeedback['block_reason'];
        if (reason is String && reason.isNotEmpty) {
          return 'Permintaan diblokir oleh filter keamanan: $reason';
        }
      }
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'Akses ke Gemini ditolak. Periksa API key.';
    }
    if (response.statusCode == 429) {
      return 'Permintaan ke Gemini dibatasi. Coba lagi setelah beberapa saat.';
    }
    if (response.statusCode >= 500) {
      return 'Layanan Gemini sedang bermasalah. Coba lagi nanti.';
    }

    return 'Gagal memproses gambar (kode ${response.statusCode}).';
  }

  void dispose() {
    _client.close();
  }
}

class AiImageResult {
  AiImageResult({
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

class AiImageTuning {
  const AiImageTuning({
    this.steps = 28,
    this.size = 1024,
    this.strength = 0.85,
    this.guidanceScale = 7.5,
  })  : assert(steps >= 0),
        assert(size >= 0),
        assert(strength >= 0),
        assert(guidanceScale >= 0);

  final int steps;
  final int size;
  final double strength;
  final double guidanceScale;

  String get descriptor =>
      'Parameter referensi -> size: ${size}px, steps: $steps, strength: ${strength.toStringAsFixed(2)}, guidance: ${guidanceScale.toStringAsFixed(2)}.';
}

class AiImageServiceException implements Exception {
  const AiImageServiceException(this.message);

  final String message;

  @override
  String toString() => 'AiImageServiceException: $message';
}
