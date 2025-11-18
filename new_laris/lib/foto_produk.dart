import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_laris/copy_writing.dart';

import 'app_colors.dart';
import 'services/ai_image_service.dart';

class TemplateSocialMediaPage extends StatefulWidget {
  const TemplateSocialMediaPage({super.key});

  @override
  State<TemplateSocialMediaPage> createState() =>
      _TemplateSocialMediaPageState();
}

class _TemplateSocialMediaPageState extends State<TemplateSocialMediaPage> {
  final List<String> _platforms = const ['Tiktok', 'Instagram', 'YouTube'];
  late String _selectedPlatform;
  final AiImageService _aiImageService = AiImageService();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  AiImageResult? _aiImageResult;
  bool _isEnhancingImage = false;
  bool _isDownloadingImage = false;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = _platforms[1];
  }

  @override
  void dispose() {
    _aiImageService.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage(
    ImageSource source, {
    bool autoEnhance = false,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxHeight: 2048,
        maxWidth: 2048,
        imageQuality: 90,
      );
      if (pickedFile == null) {
        return;
      }
      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _aiImageResult = null;
      });
      if (autoEnhance && !_isEnhancingImage) {
        await _enhanceImage(sourceBytes: bytes);
      } else {
        _showSnack('Gambar siap diproses.');
      }
    } catch (error) {
      _showSnack('Gagal mengambil gambar: $error');
    }
  }

  Future<void> _enhanceImage({Uint8List? sourceBytes}) async {
    final originalBytes = sourceBytes ?? _selectedImageBytes;
    if (originalBytes == null) {
      _showSnack('Silakan pilih gambar terlebih dahulu.');
      return;
    }

    setState(() {
      _isEnhancingImage = true;
    });

    try {
      final result = await _aiImageService.enhanceProductImage(
        originalBytes,
      );
      if (!mounted) return;
      setState(() {
        _aiImageResult = result;
      });
      _showSnack('Gambar berhasil diproses oleh AI.');
    } on AiImageServiceException catch (error) {
      _showSnack(error.message);
    } catch (error) {
      _showSnack('Terjadi kesalahan: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isEnhancingImage = false;
        });
      }
    }
  }

  Future<void> _downloadImage() async {
    final result = _aiImageResult;
    if (result == null) {
      _showSnack('Tidak ada hasil AI untuk diunduh.');
      return;
    }

    setState(() {
      _isDownloadingImage = true;
    });

    try {
      final fileName =
          'laris_${_selectedPlatform.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.${result.suggestedExtension}';
      final savedPath = await _aiImageService.downloadImage(
        result.bytes,
        fileName: fileName,
      );
      if (!mounted) return;
      _showSnack('Berhasil mengunduh gambar: $savedPath');
    } catch (error) {
      _showSnack('Gagal mengunduh gambar: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingImage = false;
        });
      }
    }
  }

  bool get _canEnhanceImage =>
      _selectedImageBytes != null && !_isEnhancingImage;

  bool get _canDownloadImage => _aiImageResult != null && !_isDownloadingImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Foto Produk',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Percantik Gambar',
                subtitle:
                    'Tingkatkan visual produk kamu otomatis dengan filter terbaik.',
              ),
              const SizedBox(height: 16),
              _buildImageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImagePreview(),
        const SizedBox(height: 18),
        _buildTipsCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _isEnhancingImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text(
                  'Pilih File',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isEnhancingImage
                    ? null
                    : () => _pickImage(
                          ImageSource.camera,
                        ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(
                  'Ambil Kamera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImageBytes != null) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _aiImageResult != null
                ? (_canDownloadImage ? _downloadImage : null)
                : (_canEnhanceImage ? _enhanceImage : null),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Builder(
              builder: (context) {
                if (_aiImageResult != null) {
                  if (_isDownloadingImage) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Mengunduh...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                  return const Text(
                    'Download Hasil',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }
                return _isEnhancingImage
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Memproses...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Percantik Gambar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      );
              },
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary05,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tips Foto Produk',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          _TipsBullet(text: 'Pastikan cahaya terang saat foto produk.'),
          _TipsBullet(
              text: 'Pastikan produk tidak terpotong dan terlihat jelas.'),
          _TipsBullet(
              text: 'Tidak terdapat gambar porno, kekerasan, atau konten sejenis.'),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final previewBytes = _aiImageResult?.bytes ?? _selectedImageBytes;
    final showResultLabel = previewBytes != null && _aiImageResult != null;

    return GestureDetector(
      onTap:
          previewBytes != null ? () => _showFullImage(previewBytes) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.primary05,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primary20),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (previewBytes != null)
                Positioned.fill(
                  child: Image.memory(
                    previewBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.image_outlined,
                        size: 62,
                        color: AppColors.primary40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada gambar',
                        style: TextStyle(color: AppColors.primary60),
                      ),
                    ],
                  ),
                ),
              if (showResultLabel || previewBytes != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildPreviewTag(
                    showResultLabel ? 'Hasil AI' : 'Siap diproses',
                    highlight: showResultLabel,
                  ),
                ),
              if (_isEnhancingImage) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTag(String label, {required bool highlight}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: highlight ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'AI sedang memoles foto...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFullImage(Uint8List bytes) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _TipsBullet extends StatelessWidget {
  const _TipsBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
