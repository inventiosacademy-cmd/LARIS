import 'package:flutter/material.dart';

import 'app_colors.dart';

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

  bool _isGenerating = false;
  _LogoPreviewData? _previewData = const _LogoPreviewData(
    name: 'BuzzyBoost',
    tagline: 'Feel the Buzz!',
    color: AppColors.primary,
    useMascot: true,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _mascotController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _generateLogo() async {
    final name = _nameController.text.trim();
    final tagline = _taglineController.text.trim();
    final colorName = _colorController.text.trim();
    final mascot = _mascotController.text.trim().toLowerCase();

    if (name.isEmpty || tagline.isEmpty) {
      _showSnack('Isi nama dan tagline terlebih dahulu.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _previewData = _LogoPreviewData(
        name: name,
        tagline: tagline,
        color: _mapColor(colorName),
        useMascot: mascot == 'yes' || mascot == 'ya' || mascot == 'true',
      );
      _isGenerating = false;
    });
  }

  Color _mapColor(String name) {
    final normalized = name.toLowerCase();
    switch (normalized) {
      case 'yellow':
      case 'kuning':
        return const Color(0xFFFFC107);
      case 'red':
      case 'merah':
        return const Color(0xFFE53935);
      case 'green':
      case 'hijau':
        return const Color(0xFF4CAF50);
      case 'blue':
      case 'biru':
        return AppColors.primary;
      case 'purple':
      case 'ungu':
        return const Color(0xFF8E24AA);
      default:
        return AppColors.primary80;
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
              if (_previewData != null)
                _LogoPreviewCard(data: _previewData!),
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

class _LogoPreviewCard extends StatelessWidget {
  const _LogoPreviewCard({required this.data});

  final _LogoPreviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.useMascot)
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bug_report_rounded,
                color: data.color,
                size: 48,
              ),
            )
          else
            Icon(
              Icons.text_fields_outlined,
              color: data.color,
              size: 48,
            ),
          const SizedBox(height: 12),
          Text(
            data.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: data.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.tagline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPreviewData {
  const _LogoPreviewData({
    required this.name,
    required this.tagline,
    required this.color,
    required this.useMascot,
  });

  final String name;
  final String tagline;
  final Color color;
  final bool useMascot;
}
