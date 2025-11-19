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
      TextEditingController(text: 'Energi Laris');
  final TextEditingController _descriptionController =
      TextEditingController(text: 'minuman energi');
  final TextEditingController _colorController =
      TextEditingController(text: 'kuning');
  final TextEditingController _taglineController =
      TextEditingController(text: 'Rasakan Semangat!');

  final AiLogoService _logoService = AiLogoService();

  bool _includeMascot = true;
  bool _isGenerating = false;
  bool _isDownloading = false;
  AiLogoResult? _logoResult;

  bool get _hasResult => _logoResult != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _taglineController.dispose();
    _logoService.dispose();
    super.dispose();
  }

  Future<void> _generateLogo() async {
    setState(() {
      _isGenerating = true;
      _logoResult = null;
    });

    try {
      final result = await _logoService.generateLogo(
        productName: _nullableValue(_nameController.text),
        productType: _nullableValue(_descriptionController.text),
        primaryColor: _nullableValue(_colorController.text),
        mascotPreference: _includeMascot ? 'ya' : 'tidak',
        tagline: _nullableValue(_taglineController.text),
      );
      if (!mounted) return;
      setState(() {
        _logoResult = result;
      });
      _showSnack('Logo berhasil dibuat. Tekan "Unduh Logo" untuk menyimpannya.');
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

  Widget _buildMascotCheckbox(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CheckboxListTile(
          value: _includeMascot,
          onChanged: (value) {
            setState(() {
              _includeMascot = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Text(
            'Tambahkan Maskot',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            'Jika dicentang, maskot akan ikut ditambahkan pada logo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final theme = Theme.of(context);
    final result = _logoResult;
    final bytes = result?.bytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Logo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bytes != null)
                  Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: AppColors.primary40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada logo yang ditampilkan',
                          style: TextStyle(
                            color: AppColors.primary60,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isGenerating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'AI sedang menggambar logo...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          result != null
              ? 'Format: ${result.mimeType} | Tekan "Unduh Logo" untuk menyimpannya.'
              : 'Belum ada logo. Lengkapi form dan tekan "Buat Logo".',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrimaryButtonChild() {
    if (_isGenerating || _isDownloading) {
      final label = _isGenerating ? 'Membuat Logo...' : 'Mengunduh Logo...';
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      );
    }
    return Text(_hasResult ? 'Unduh Logo' : 'Buat Logo');
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
          'Buat Logo',
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
              _buildResultSection(context),
              _FormField(
                label: 'Nama Brand',
                controller: _nameController,
              ),
              _FormField(
                label: 'Deskripsi Produk',
                controller: _descriptionController,
              ),
              _FormField(
                label: 'Warna Utama',
                controller: _colorController,
              ),
              _buildMascotCheckbox(context),
              _FormField(
                label: 'Slogan',
                controller: _taglineController,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isGenerating || _isDownloading)
                      ? null
                      : (_hasResult ? _downloadLogo : _generateLogo),
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
                  child: _buildPrimaryButtonChild(),
                ),
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

