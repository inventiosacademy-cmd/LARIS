import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

class AiGeneratePosterService {
  AiGeneratePosterService({
    http.Client? client,
    String? apiKey,
    String? model,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _apiKey = _resolveApiKey(apiKey),
        _model = _resolveModel(model),
        _timeout = timeout ?? _defaultTimeout;

  static const Duration _defaultTimeout = Duration(minutes: 2);
  static const String _defaultModel = 'gemini-2.5-flash-image';
  static const String _envGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String _galleryAlbumName = 'Laris Poster AI';

  final http.Client _client;
  final String _apiKey;
  final String _model;
  final Duration _timeout;

  Uri get _endpoint => Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/$_model:generateContent',
        {'key': _apiKey},
      );

  Future<AiPosterResult> generatePoster({
    required List<Uint8List> photos,
    required String brandName,
    required String productDescription,
    String? price,
    String? promo,
    String? location,
    String? contact,
  }) async {
    if (photos.isEmpty) {
      throw const AiGeneratePosterServiceException(
        'Tambahkan minimal satu foto produk sebelum membuat poster.',
      );
    }
    final trimmedBrand = brandName.trim();
    final trimmedDescription = productDescription.trim();
    if (trimmedBrand.isEmpty || trimmedDescription.isEmpty) {
      throw const AiGeneratePosterServiceException(
        'Nama brand dan keterangan produk wajib diisi.',
      );
    }

    final prompt = _composePrompt(
      brandName: trimmedBrand,
      productDescription: trimmedDescription,
      price: price?.trim(),
      promo: promo?.trim(),
      location: location?.trim(),
      contact: contact?.trim(),
    );

    final payload = _buildRequestPayload(prompt: prompt, photos: photos);
    final response = await _sendRequest(payload);
    if (response.statusCode >= 400) {
      throw AiGeneratePosterServiceException(_extractErrorMessage(response));
    }
    final parsed = _tryDecodeJson(response);
    if (parsed == null) {
      throw const AiGeneratePosterServiceException(
        'Gemini tidak mengembalikan respons poster yang valid.',
      );
    }
    final inline = _firstInlineData(parsed);
    if (inline != null) {
      return AiPosterResult(
        bytes: inline.bytes,
        mimeType: inline.mimeType,
        prompt: prompt,
      );
    }
    final fallback = _firstCandidateText(parsed);
    if (fallback != null && fallback.isNotEmpty) {
      throw AiGeneratePosterServiceException(fallback);
    }
    throw const AiGeneratePosterServiceException(
      'Gemini tidak mengembalikan data poster.',
    );
  }

  Future<String> downloadPoster(
    Uint8List bytes, {
    String? fileName,
  }) async {
    final resolvedName = _sanitizeFileName(
      fileName ??
          'laris_poster_${kIsWeb ? 'web' : 'device'}_${DateTime.now().millisecondsSinceEpoch}.png',
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
    if (_supportsGallerySaver) {
      return _saveToGallery(bytes, resolvedName);
    }
    final targetDir = await _resolveDownloadDirectory();
    final file = io.File('${targetDir.path}${io.Platform.pathSeparator}$resolvedName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  bool get _supportsGallerySaver =>
      !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);

  Future<String> _saveToGallery(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}${io.Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final tempFile = io.File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);
    final saved = await GallerySaver.saveImage(
      tempFile.path,
      albumName: _galleryAlbumName,
    );
    await tempFile.delete().catchError((_) {});
    if (saved == true) {
      return 'Galeri (album $_galleryAlbumName)';
    }
    throw const AiGeneratePosterServiceException(
      'Gagal menyimpan poster ke galeri. Pastikan izin penyimpanan tersedia.',
    );
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
      // ignore
    }

    final documents = await getApplicationDocumentsDirectory();
    return io.Directory(documents.path);
  }

  Map<String, Object?> _buildRequestPayload({
    required String prompt,
    required List<Uint8List> photos,
  }) {
    final parts = <Map<String, Object?>>[
      {'text': prompt},
    ];
    for (final bytes in photos) {
      final mimeType = lookupMimeType('', headerBytes: bytes) ?? 'image/png';
      parts.add(
        {
          'inlineData': {
            'mimeType': mimeType,
            'data': base64Encode(bytes),
          },
        },
      );
    }
    return {
      'contents': [
        {
          'role': 'user',
          'parts': parts,
        },
      ],
      'generationConfig': {
        'temperature': 0.6,
        'topP': 0.9,
      },
    };
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
      throw AiGeneratePosterServiceException(
        'Permintaan poster melebihi ${_timeout.inSeconds} detik.',
      );
    } on http.ClientException catch (error) {
      throw AiGeneratePosterServiceException(
        'Gagal terhubung ke layanan Gemini: ${error.message}',
      );
    } catch (error) {
      throw AiGeneratePosterServiceException(
        'Gagal mengirim permintaan: $error',
      );
    }
  }

  String _composePrompt({
    required String brandName,
    required String productDescription,
    String? price,
    String? promo,
    String? location,
    String? contact,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Buat grafik desain poster marketing profesional dengan ketentuan berikut:',
      )
      ..writeln(
        '1. Jika foto yang diunggah kurang jelas atau blur, otomatis perindah dengan penyesuaian pencahayaan, pengurangan noise, peningkatan kontras, dan penajaman sehingga produk tampak bersih dan menarik.',
      )
      ..writeln(
        '2. Susun tata letak modern dan elegan seperti poster promosi profesional dengan fokus utama pada produk, tipografi premium, dan komposisi rapi bernuansa studio katalog.',
      )
      ..writeln('3. Output harus berupa gambar poster siap pakai, bukan teks.')
      ..writeln('Masukkan informasi berikut:')
      ..writeln('- Nama Brand / Jasa: $brandName')
      ..writeln('- Keterangan Jasa / Produk: $productDescription');

    if (price != null && price.isNotEmpty) {
      buffer.writeln('- Harga: $price');
    } else {
      buffer.writeln('- Harga: (opsional, tampilkan hanya jika tersedia).');
    }

    if (promo != null && promo.isNotEmpty) {
      buffer.writeln('- Promo: $promo');
    } else {
      buffer.writeln('- Promo: (opsional, abaikan jika tidak diisi).');
    }

    if (location != null && location.isNotEmpty) {
      buffer.writeln('- Lokasi: $location');
    } else {
      buffer.writeln('- Lokasi: (opsional, abaikan jika kosong).');
    }

    if (contact != null && contact.isNotEmpty) {
      buffer.writeln('- Kontak: $contact');
    } else {
      buffer.writeln('- Kontak: (opsional, jangan buat placeholder apabila kosong).');
    }

    buffer
      .writeln('Berikan satu gambar final tanpa teks instruksi tambahan.');

    return buffer.toString().trim();
  }

  dynamic _tryDecodeJson(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded;
    } catch (_) {
      return null;
    }
  }

  _PosterInlineData? _firstInlineData(dynamic parsed) {
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
                      final mimeType =
                          inline['mimeType'] ?? inline['mime_type'] ?? 'image/png';
                      if (data is String && data.isNotEmpty) {
                        try {
                          return _PosterInlineData(
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
                for (final part in parts) {
                  if (part is Map) {
                    final text = part['text'];
                    if (text is String && text.isNotEmpty) {
                      return text;
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
      final candidateText = _firstCandidateText(parsed);
      if (candidateText != null && candidateText.isNotEmpty) {
        return candidateText;
      }
      final promptFeedback = parsed['promptFeedback'];
      if (promptFeedback is Map) {
        final reason =
            promptFeedback['blockReason'] ?? promptFeedback['block_reason'];
        if (reason is String && reason.isNotEmpty) {
          return 'Permintaan diblokir: $reason';
        }
      }
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'API key Gemini tidak valid.';
    }
    if (response.statusCode == 429) {
      return 'Permintaan terlalu sering. Coba beberapa saat lagi.';
    }
    if (response.statusCode >= 500) {
      return 'Layanan Gemini sedang bermasalah. Coba lagi nanti.';
    }
    return 'Gagal membuat poster (kode ${response.statusCode}).';
  }

  static String _resolveApiKey(String? provided) {
    final trimmed = provided?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    if (_envGeminiApiKey.isNotEmpty) {
      return _envGeminiApiKey;
    }
    throw const AiGeneratePosterServiceException(
      'Gemini API key belum dikonfigurasi. Tambahkan --dart-define=GEMINI_API_KEY=YOUR_KEY '
      'saat build/run atau berikan langsung ke AiGeneratePosterService.',
    );
  }

  static String _resolveModel(String? provided) {
    const envModel = String.fromEnvironment(
      'GEMINI_POSTER_MODEL',
      defaultValue: _defaultModel,
    );
    final candidate =
        (provided?.trim().isNotEmpty ?? false) ? provided!.trim() : envModel;
    final lower = candidate.toLowerCase();
    if (lower == 'nano banana' || lower == 'nano-banana') {
      return 'imagen-3.0-nano-banana';
    }
    return candidate;
  }

  String _sanitizeFileName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'laris_poster.png' : sanitized;
  }

  void dispose() {
    _client.close();
  }
}

class AiPosterResult {
  const AiPosterResult({
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

class AiGeneratePosterServiceException implements Exception {
  const AiGeneratePosterServiceException(this.message);

  final String message;

  @override
  String toString() => 'AiGeneratePosterServiceException: $message';
}

class _PosterInlineData {
  const _PosterInlineData({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}
