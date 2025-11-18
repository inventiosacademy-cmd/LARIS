import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'services/ai_logo_service.dart';

class GenerateLogoPage extends StatefulWidget {
  const GenerateLogoPage({super.key});

  @override
  State<GenerateLogoPage> createState() => _GenerateLogoPageState();
}

class _GenerateLogoPageState extends State<GenerateLogoPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'BuzzyBoost');
  final TextEditingController _descriptionController =
      TextEditingController(text: 'energy drink');
  final TextEditingController _colorController =
      TextEditingController(text: 'yellow');
  final TextEditingController _mascotController =
      TextEditingController(text: 'yes');
  final TextEditingController _taglineController =
      TextEditingController(text: 'Feel the Buzz!');

  final AiLogoService _logoService = AiLogoService();

  bool _isGenerating = false;
  bool _isDownloading = false;
  AiLogoResult? _logoResult;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _mascotController.dispose();
    _taglineController.dispose();
    _logoService.dispose();
    super.dispose();
  }

  Future<void> _generateLogo() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await _logoService.generateLogo(
        productName: _nullableValue(_nameController.text),
        productType: _nullableValue(_descriptionController.text),
        primaryColor: _nullableValue(_colorController.text),
        mascotPreference: _normalizeMascotPreference(_mascotController.text),
        tagline: _nullableValue(_taglineController.text),
      );
      if (!mounted) return;
      setState(() {
        _logoResult = result;
      });
      _showSnack('Logo berhasil dibuat.');
    } on AiLogoServiceException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } catch (error) {
      if (!mounted) return;
      _showSnack('Gagal membuat logo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  String? _nullableValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizeMascotPreference(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final lower = trimmed.toLowerCase();
    const yesSet = {'ya', 'yes', 'y', 'true', 'pakai', 'gunakan'};
    const noSet = {'tidak', 'no', 'n', 'false', 'ga', 'gak', 'nggak'};
    if (yesSet.contains(lower)) {
      return 'ya';
    }
    if (noSet.contains(lower)) {
      return 'tidak';
    }
    return trimmed;
  }

  Future<void> _downloadLogo() async {
    final result = _logoResult;
    if (result == null) {
      _showSnack('Belum ada logo untuk diunduh.');
      return;
    }
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
    });
    try {
      final baseName = _nullableValue(_nameController.text) ?? 'laris_logo';
      final fileName =
          '${baseName.replaceAll(RegExp(r"[^a-zA-Z0-9_-]"), "_")}_${DateTime.now().millisecondsSinceEpoch}.${result.suggestedExtension}';
      final path = await _logoService.downloadLogo(
        result.bytes,
        fileName: fileName,
      );
      if (!mounted) return;
      _showSnack('Logo tersimpan di $path');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Gagal mengunduh logo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Generate a Logo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormField(
                label: 'Name',
                controller: _nameController,
              ),
              _FormField(
                label: 'Description',
                controller: _descriptionController,
              ),
              _FormField(
                label: 'Color',
                controller: _colorController,
              ),
              _FormField(
                label: 'Include mascot',
                controller: _mascotController,
              ),
              _FormField(
                label: 'Tagline',
                controller: _taglineController,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateLogo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Generate Logo'),
                ),
              ),
              const SizedBox(height: 20),
              _LogoResultCard(
                isLoading: _isGenerating,
                isDownloading: _isDownloading,
                result: _logoResult,
                onDownload: _downloadLogo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoResultCard extends StatelessWidget {
  const _LogoResultCard({
    required this.isLoading,
    required this.isDownloading,
    required this.result,
    required this.onDownload,
  });

  final bool isLoading;
  final bool isDownloading;
  final AiLogoResult? result;
  final Future<void> Function()? onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = result?.bytes;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hasil Logo dari Gemini',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            Row(
              children: const [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI sedang menggambar logo terbaik untukmu...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            )
          else if (result == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.primary),
                SizedBox(height: 8),
                Text(
                  'Isi form di atas lalu tekan "Generate Logo" untuk melihat hasil gambar dari Gemini.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 230,
                    decoration: BoxDecoration(
                      color: AppColors.primary05,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.primary20),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (bytes != null)
                          Positioned.fill(
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.image_outlined,
                                  size: 58,
                                  color: AppColors.primary40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Belum ada hasil logo',
                                  style: TextStyle(color: AppColors.primary60),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: _buildPreviewTag(
                            bytes != null ? 'Hasil AI' : 'Belum ada hasil',
                            highlight: bytes != null,
                          ),
                        ),
                        if (isLoading) _buildLoadingOverlay(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.image_outlined,
                        size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Format: ${result!.mimeType} | Simpan atau download untuk dipakai di brand-mu.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: (onDownload == null || isDownloading)
                      ? null
                      : () {
                          onDownload?.call();
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: isDownloading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    isDownloading ? 'Mengunduh...' : 'Download Logo',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
        ],
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
      color: Colors.black.withValues(alpha: 0.35),
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
          SizedBox(height: 10),
          Text(
            'AI sedang menggambar logo...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
