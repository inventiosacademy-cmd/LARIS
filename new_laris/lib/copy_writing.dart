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
  final List<String> _platforms = const [
    'Instagram',
    'TikTok Shop',
    'Shopee Live',
    'WhatsApp Broadcast',
    'Marketplace',
  ];
  late String _selectedPlatform;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
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
    _productSpecialController.dispose();
    _productLinkController.dispose();
    _contactNumberController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onPlatformChanged(String platform) {
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
    final productLink = _productLinkController.text.trim();
    final contactNumber = _contactNumberController.text.trim();

    if (productName.isEmpty || productType.isEmpty) {
      _showSnack('Nama dan jenis produk wajib diisi.');
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
    required String productLink,
    required String contactNumber,
  }) {
    final tone = _platformGuideline(_selectedPlatform);
    final buffer = StringBuffer()
      ..writeln(
          'Kamu adalah copywriter profesional untuk UMKM kuliner Indonesia.')
      ..writeln(
          'Tulis satu copywriting ${_selectedPlatform.toLowerCase()} yang persuasif dan siap posting.')
      ..writeln('Nama produk: $name')
      ..writeln('Jenis produk: $type');

    if (special.isNotEmpty) {
      buffer.writeln('Ciri khusus produk: $special');
    }
    if (productLink.isNotEmpty) {
      buffer.writeln('Link produk atau katalog: $productLink');
    }
    if (contactNumber.isNotEmpty) {
      buffer.writeln('Kontak/WhatsApp pemesanan: $contactNumber');
    }

    buffer
      ..writeln('Gaya bahasa: $tone')
      ..writeln(
          'Gunakan Bahasa Indonesia natural, maksimal tiga paragraf pendek.')
      ..writeln(
          'Tambahkan ajakan bertindak yang kuat dan 3-5 hashtag relevan di akhir.');
    if (productLink.isNotEmpty || contactNumber.isNotEmpty) {
      buffer.writeln(
        'Pastikan CTA mengarahkan ke link/kontak tersebut agar pembaca tahu cara order.',
      );
    }

    return buffer.toString();
  }

  String _platformGuideline(String platform) {
    switch (platform) {
      case 'Instagram':
        return 'Storytelling estetik, gunakan emoji secukupnya, akhiri dengan CTA seperti "cek link di bio" atau "tap buat lihat katalog".';
      case 'TikTok Shop':
        return 'Hook kuat di 2 detik pertama, kalimat pendek penuh energi, sertakan CTA "checkout sekarang" dan highlight stok terbatas.';
      case 'Shopee Live':
        return 'Gunakan bahasa percakapan layaknya host live, sebut promo dan bonus, akhiri dengan CTA "serbu sekarang sebelum habis".';
      case 'WhatsApp Broadcast':
        return 'Bahasa personal, hangat, beri sapaan singkat, tawarkan promo terbatas dan ajak balas chat untuk order.';
      case 'Marketplace':
      default:
        return 'Tekankan manfaat dan detail produk, sertakan bukti sosial singkat, sebut harga atau bonus, tutup dengan CTA "beli sekarang".';
    }
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
                productSpecialController: _productSpecialController,
                productLinkController: _productLinkController,
                contactNumberController: _contactNumberController,
                onPlatformChanged: _onPlatformChanged,
                onBeautifyPressed: _onBeautifyPressed,
                onCopyPressed: _onCopyPressed,
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

  final String platform;
  final bool isLoading;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 12),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copywriting untuk $platform',
            style: theme.textTheme.titleSmall?.copyWith(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.primary40),
                SizedBox(height: 8),
                Text(
                  'Hasil copywriting akan tampil di sini setelah tombol "Percantik dengan AI" ditekan.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            )
          else
            SelectableText(
              text!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
        ],
      ),
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
    required this.productSpecialController,
    required this.productLinkController,
    required this.contactNumberController,
    required this.onPlatformChanged,
    required this.onBeautifyPressed,
    required this.onCopyPressed,
  });

  final List<String> platforms;
  final String selectedPlatform;
  final TextEditingController productNameController;
  final TextEditingController productTypeController;
  final TextEditingController productSpecialController;
  final TextEditingController productLinkController;
  final TextEditingController contactNumberController;
  final ValueChanged<String> onPlatformChanged;
  final VoidCallback onBeautifyPressed;
  final VoidCallback onCopyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 12),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copywriting untuk platform apa?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms
                .map(
                  (platform) => ChoiceChip(
                    label: Text(platform),
                    selected: selectedPlatform == platform,
                    onSelected: (_) => onPlatformChanged(platform),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedPlatform == platform
                          ? Colors.white
                          : AppColors.primary60,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.primary05,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          _buildFieldLabel(
            theme,
            label: 'Nama Produk',
            required: true,
          ),
          const SizedBox(height: 6),
          TextField(
            controller: productNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Contoh: Keripik Pisang Laris',
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
          const SizedBox(height: 8),
          Text(
            'Nama produk dan jenis produk wajib diisi sebelum meneruskan ke AI.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Link produk dan nomor kontak opsional, namun AI akan memasukkannya ke CTA jika tersedia.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          TemplateInfoTile(
            icon: Icons.campaign_outlined,
            title: 'Ajakan bertindak otomatis',
            subtitle:
                'CTA akan disesuaikan untuk ${selectedPlatform.toLowerCase()}.',
          ),
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
          const SizedBox(height: 12),
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
      ),
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
          color: AppColors.primary,
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

class TemplateInfoTile extends StatelessWidget {
  const TemplateInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary05,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
