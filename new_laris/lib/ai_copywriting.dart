import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'services/ai_copywriting_service.dart';

class AiCopywritingPage extends StatefulWidget {
  const AiCopywritingPage({super.key});

  @override
  State<AiCopywritingPage> createState() => _AiCopywritingPageState();
}

class _AiCopywritingPageState extends State<AiCopywritingPage> {
  final TextEditingController _themeController = TextEditingController(
    text: 'Keripik pisang premium yang gurih dan renyah',
  );
  final Set<AiCopywritingPreset> _selectedPresets = {
    AiCopywritingPreset.tiktok,
  };
  final Map<AiCopywritingPreset, String> _results = {};
  final AiCopywritingService _service = AiCopywritingService();

  bool _isGenerating = false;

  @override
  void dispose() {
    _themeController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _togglePreset(AiCopywritingPreset preset, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedPresets.add(preset);
      } else {
        _selectedPresets.remove(preset);
      }
    });
  }

  Future<void> _generateCopywriting() async {
    final theme = _themeController.text.trim();
    if (theme.isEmpty) {
      _showSnack('Isi tema copywriting terlebih dahulu.');
      return;
    }
    if (_selectedPresets.isEmpty) {
      _showSnack('Pilih minimal satu platform copywriting.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final newResults = <AiCopywritingPreset, String>{};
    try {
      for (final preset in _selectedPresets) {
        final prompt =
            preset.promptTemplate.replaceAll('[ISI TEMAMU]', theme.trim());
        final text = await _service.generateCopywriting(prompt);
        newResults[preset] = text;
      }
      setState(() {
        _results
          ..clear()
          ..addAll(newResults);
      });
      _showSnack('Copywriting berhasil digenerate.');
    } on AiCopywritingServiceException catch (error) {
      _showSnack(error.message);
    } catch (error) {
      _showSnack('Gagal meminta copywriting: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Copywriting disalin.');
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
      backgroundColor: AppColors.primary05,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'AI Copywriting',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
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
              Text(
                'Tema Copywriting',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _themeController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Launching rasa cokelat terbaru',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.primary20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Kanal Konten',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              ...AiCopywritingPreset.values.map(
                (preset) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedPresets.contains(preset)
                          ? AppColors.primary40
                          : AppColors.primary10,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: _selectedPresets.contains(preset),
                    onChanged: (value) => _togglePreset(preset, value),
                    title: Text(
                      preset.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    subtitle: Text(
                      preset.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary60,
                      ),
                    ),
                    secondary: Icon(
                      preset.icon,
                      color: AppColors.primary,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isGenerating ? null : _generateCopywriting,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Meminta AI...',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : const Text(
                        'Percantik dengan AI',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
              if (_isGenerating) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary10,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Hasil Copywriting',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              if (_results.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary10),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_fix_high_rounded,
                        color: AppColors.primary40,
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hasil akan tampil di sini setelah kamu klik Percantik.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary60,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _results.entries
                      .map(
                        (entry) => _CopywritingResultCard(
                          preset: entry.key,
                          text: entry.value,
                          onCopy: () => _copyResult(entry.value),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopywritingResultCard extends StatelessWidget {
  const _CopywritingResultCard({
    required this.preset,
    required this.text,
    required this.onCopy,
  });

  final AiCopywritingPreset preset;
  final String text;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary05,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(preset.icon, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      preset.shortLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
                color: AppColors.primary,
                tooltip: 'Salin hasil',
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectableText(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.primary80,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

enum AiCopywritingPreset { tiktok, instagram, facebook }

extension AiCopywritingPresetX on AiCopywritingPreset {
  String get title {
    switch (this) {
      case AiCopywritingPreset.tiktok:
        return 'Copywriting TikTok';
      case AiCopywritingPreset.instagram:
        return 'Copywriting Instagram';
      case AiCopywritingPreset.facebook:
        return 'Copywriting Facebook';
    }
  }

  String get shortLabel {
    switch (this) {
      case AiCopywritingPreset.tiktok:
        return 'TikTok';
      case AiCopywritingPreset.instagram:
        return 'Instagram';
      case AiCopywritingPreset.facebook:
        return 'Facebook';
    }
  }

  IconData get icon {
    switch (this) {
      case AiCopywritingPreset.tiktok:
        return Icons.flash_on_rounded;
      case AiCopywritingPreset.instagram:
        return Icons.photo_camera_rounded;
      case AiCopywritingPreset.facebook:
        return Icons.facebook_rounded;
    }
  }

  String get subtitle {
    switch (this) {
      case AiCopywritingPreset.tiktok:
        return 'Hook kuat 2 detik pertama + hashtag viral';
      case AiCopywritingPreset.instagram:
        return 'Storytelling estetik, emosional, dan brandable';
      case AiCopywritingPreset.facebook:
        return 'Lebih panjang, informatif, dan meyakinkan';
    }
  }

  String get promptTemplate {
    switch (this) {
      case AiCopywritingPreset.tiktok:
        return '''
Buatkan copywriting bergaya TikTok yang sangat singkat, enerjik, dan punya hook kuat di 2 detik pertama. Gunakan bahasa yang santai, mudah diingat, dan relevan untuk Gen Z. Sertakan ajakan interaksi seperti "komen", "like", atau "cek link di bio". Tulis dengan format ringkas, maksimal 2–3 kalimat. Tambahkan 5–10 hashtag pendek dan viral. Tema: [ISI TEMAMU].
''';
      case AiCopywritingPreset.instagram:
        return '''
Buatkan copywriting Instagram yang estetik dan memiliki sentuhan storytelling. Gunakan bahasa yang elegan, penuh emosi positif, dan membangun brand image yang kuat. Formatkan dalam paragraf singkat, lalu berikan call to action seperti "swipe", "save", atau "share". Tambahkan 8–12 hashtag yang relevan dan trending namun tetap niche. Tema: [ISI TEMAMU].
''';
      case AiCopywritingPreset.facebook:
        return '''
Buatkan copywriting Facebook yang lebih panjang, informatif, dan persuasive. Gunakan bahasa yang sopan, jelas, dan mudah dipahami oleh audiens dewasa. Sertakan manfaat utama, alasan rasional, serta ajakan bertindak yang kuat seperti "pelajari lebih lanjut", "hubungi kami", atau "klik link ini". Tambahkan 5–8 hashtag relevan yang tidak harus viral tetapi spesifik. Tema: [ISI TEMAMU].
''';
    }
  }
}
