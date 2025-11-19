import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'services/ai_copywriting_service.dart';

class CopyWritingPage extends StatefulWidget {
  const CopyWritingPage({super.key});

  @override
  State<CopyWritingPage> createState() => _CopyWritingPageState();
}

class _CopyWritingPageState extends State<CopyWritingPage> {
  final List<AiCopywritingPreset> _platforms = const [
    AiCopywritingPreset.tiktok,
    AiCopywritingPreset.instagram,
    AiCopywritingPreset.facebook,
    AiCopywritingPreset.tokopedia,
    AiCopywritingPreset.shopee,
  ];
  late AiCopywritingPreset _selectedPlatform;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  final TextEditingController _productSpecialController =
      TextEditingController();
  final TextEditingController _productLinkController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  final AiCopywritingService _service = AiCopywritingService();

  bool _isBeautifying = false;
  String? _generatedCopy;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = _platforms.first;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productTypeController.dispose();
    _taglineController.dispose();
    _productSpecialController.dispose();
    _productLinkController.dispose();
    _contactNumberController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onPlatformChanged(AiCopywritingPreset platform) {
    if (_selectedPlatform == platform) {
      return;
    }
    setState(() {
      _selectedPlatform = platform;
    });
  }

  Future<void> _onBeautifyPressed() async {
    if (_isBeautifying) return;
    final productName = _productNameController.text.trim();
    final productType = _productTypeController.text.trim();
    final productSpecial = _productSpecialController.text.trim();
    final tagline = _taglineController.text.trim();
    final productLink = _productLinkController.text.trim();
    final contactNumber = _contactNumberController.text.trim();

    if (productName.isEmpty || productType.isEmpty) {
      _showSnack('Nama brand dan jenis produk wajib diisi.');
      return;
    }

    setState(() {
      _isBeautifying = true;
    });

    try {
      final prompt = _buildPrompt(
        name: productName,
        type: productType,
        special: productSpecial,
        tagline: tagline,
        productLink: productLink,
        contactNumber: contactNumber,
      );
      final copy = await _service.generateCopywriting(prompt);
      if (!mounted) return;
      setState(() {
        _generatedCopy = copy;
      });
      _showSnack('Copywriting berhasil dibuat.');
    } on AiCopywritingServiceException catch (error) {
      _showSnack(error.message);
    } catch (error) {
      _showSnack('Gagal meminta copywriting: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isBeautifying = false;
        });
      }
    }
  }

  void _onCopyPressed() {
    final text = _generatedCopy;
    if (text == null || text.trim().isEmpty) {
      _showSnack('Belum ada copywriting untuk disalin.');
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Copywriting disalin.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _buildPrompt({
    required String name,
    required String type,
    required String special,
    required String tagline,
    required String productLink,
    required String contactNumber,
  }) {
    final summary = _composeThemeSummary(
      name: name,
      type: type,
      special: special,
      tagline: tagline,
      productLink: productLink,
      contactNumber: contactNumber,
    );
    final template = _selectedPlatform.promptTemplate;
    return template.replaceAll('[ISI TEMAMU]', summary);
  }

  String _composeThemeSummary({
    required String name,
    required String type,
    required String special,
    required String tagline,
    required String productLink,
    required String contactNumber,
  }) {
    final parts = <String>[
      'Brand $name dengan jenis produk $type',
    ];
    if (tagline.isNotEmpty) {
      parts.add('Tagline: "$tagline"');
    }
    if (special.isNotEmpty) {
      parts.add('Keunggulan utama: $special');
    }
    if (productLink.isNotEmpty) {
      parts.add('Link pembelian: $productLink');
    }
    if (contactNumber.isNotEmpty) {
      parts.add('Kontak/WhatsApp: $contactNumber');
    }
    return parts.join('. ');
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
        title: Text(
          'Copywriting AI',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopyWritingSection(
                platforms: _platforms,
                selectedPlatform: _selectedPlatform,
                productNameController: _productNameController,
                productTypeController: _productTypeController,
                taglineController: _taglineController,
                productSpecialController: _productSpecialController,
                productLinkController: _productLinkController,
                contactNumberController: _contactNumberController,
                onPlatformChanged: _onPlatformChanged,
                onBeautifyPressed: _onBeautifyPressed,
                onCopyPressed: _onCopyPressed,
                hasResult:
                    _generatedCopy != null && _generatedCopy!.trim().isNotEmpty,
              ),
              const SizedBox(height: 20),
              _CopywritingPreviewCard(
                platform: _selectedPlatform,
                isLoading: _isBeautifying,
                text: _generatedCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopywritingPreviewCard extends StatelessWidget {
  const _CopywritingPreviewCard({
    required this.platform,
    required this.isLoading,
    required this.text,
  });

  final AiCopywritingPreset platform;
  final bool isLoading;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          Row(
            children: const [
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI sedang merangkai copywriting terbaik...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          )
        else if (text == null)
          const SizedBox.shrink()
        else
          SelectableText(
            text!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}

class CopyWritingSection extends StatelessWidget {
  const CopyWritingSection({
    super.key,
    required this.platforms,
    required this.selectedPlatform,
    required this.productNameController,
    required this.productTypeController,
    required this.taglineController,
    required this.productSpecialController,
    required this.productLinkController,
    required this.contactNumberController,
    required this.onPlatformChanged,
    required this.onBeautifyPressed,
    required this.onCopyPressed,
    required this.hasResult,
  });

  final List<AiCopywritingPreset> platforms;
  final AiCopywritingPreset selectedPlatform;
  final TextEditingController productNameController;
  final TextEditingController productTypeController;
  final TextEditingController taglineController;
  final TextEditingController productSpecialController;
  final TextEditingController productLinkController;
  final TextEditingController contactNumberController;
  final ValueChanged<AiCopywritingPreset> onPlatformChanged;
  final VoidCallback onBeautifyPressed;
  final VoidCallback onCopyPressed;
  final bool hasResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          theme,
          label: 'Nama Brand',
          required: true,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: productNameController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hint: 'Contoh: Laris Snack House',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Jenis Produk',
          required: true,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: productTypeController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hint: 'Contoh: Snack premium tanpa pengawet',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Tagline Brand / Produk',
        ),
        const SizedBox(height: 6),
        TextField(
          controller: taglineController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hint: 'Contoh: "Gurihnya bikin nagih setiap gigitan"',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Ciri Khusus Produk',
        ),
        const SizedBox(height: 6),
        TextField(
          controller: productSpecialController,
          maxLines: 3,
          decoration: _inputDecoration(
            hint: 'Contoh: Renyah, tidak berminyak, banyak varian rasa',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Link Produk / Landing Page',
        ),
        const SizedBox(height: 6),
        TextField(
          controller: productLinkController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.url,
          decoration: _inputDecoration(
            hint: 'Contoh: https://tokokamu.com/keripik',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Nomor Kontak / WhatsApp',
        ),
        const SizedBox(height: 6),
        TextField(
          controller: contactNumberController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hint: 'Contoh: 0812-3456-7890',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel(
          theme,
          label: 'Copywriting untuk apa?',
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<AiCopywritingPreset>(
          value: selectedPlatform,
          decoration: _inputDecoration(hint: 'Pilih platform tujuan'),
          items: platforms
              .map(
                (platform) => DropdownMenuItem<AiCopywritingPreset>(
                  value: platform,
                  child: Text(platform.shortLabel),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onPlatformChanged(value);
            }
          },
        ),
        if (hasResult) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onCopyPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Copy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onBeautifyPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Percantik dengan AI',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(
    ThemeData theme, {
    required String label,
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.primary05,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black87),
      ),
    );
  }
}
