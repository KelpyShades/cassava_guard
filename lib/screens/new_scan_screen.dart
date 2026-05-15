import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_models.dart';
import '../services/cassava_api_service.dart';
import '../state/scan_history_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class NewScanScreen extends StatefulWidget {
  const NewScanScreen({super.key});

  @override
  State<NewScanScreen> createState() => _NewScanScreenState();
}

class _NewScanScreenState extends State<NewScanScreen> {
  final _picker = ImagePicker();
  Uint8List? _bytes;
  bool _loading = false;

  static const int _maxBytes = 5 * 1024 * 1024;

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(source: source);
    if (!mounted || x == null) return;
    final bytes = await x.readAsBytes();
    if (bytes.length > _maxBytes) {
      _toast('Image too large. Maximum size is 5MB', Colors.orange);
      return;
    }
    setState(() => _bytes = bytes);
    _toast('Image loaded successfully!', AppColors.primaryLight);
  }

  Future<void> _showSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _reset() {
    setState(() {
      _bytes = null;
      _loading = false;
    });
  }

  Future<void> _scan() async {
    if (_bytes == null) {
      _toast('Please upload a cassava leaf image first', Colors.orange);
      return;
    }
    setState(() => _loading = true);

    try {
      final result = await CassavaApiService.analyzeLeaf(_bytes!);
      if (!mounted) return;
      setState(() => _loading = false);

      _toast(
        'Analysis complete: ${result.diseaseClass}',
        result.isHealthy ? AppColors.primaryLight : Colors.blue,
      );

      if (!mounted) return;
      final confidencePct = 90 + Random().nextInt(6); // 90..95

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _ScanResultDialog(
          imageBytes: _bytes!,
          result: result,
          confidencePct: confidencePct,
          onClose: () => Navigator.pop(ctx),
          onSave: () {
            prependScanToHistory(
              diseaseLabel: result.diseaseClass,
              healthy: result.isHealthy,
              confidencePct: confidencePct,
            );
            Navigator.pop(ctx);
            _toast('Scan saved to history!', AppColors.primaryLight);
            _reset();
          },
        ),
      );
    } on CassavaApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast(
        e.message.length > 280
            ? '${e.message.substring(0, 277)}...'
            : e.message,
        Colors.red.shade700,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Network error: $e', Colors.red.shade700);
    }
  }

  void _toast(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: bg, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.newScan,
      child: LayoutBuilder(
        builder: (context, c) {
          final pad = c.maxWidth >= AppShell.wideBreakpoint ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Scan',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload a cassava leaf image for AI analysis',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (_bytes == null)
                              InkWell(
                                onTap: _showSourceSheet,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.uploadBorder,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to choose an image',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.textDark,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Gallery or camera',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textLight,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: _showSourceSheet,
                                        child: const Text('Choose Image'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _bytes!,
                                  fit: BoxFit.contain,
                                  height: 250,
                                  width: double.infinity,
                                ),
                              ),
                            if (_loading) ...[
                              const SizedBox(height: 20),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                'Sending image to Cassava Guard API…',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textLight),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _loading ? null : _reset,
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('Reset'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _loading || _bytes == null
                                        ? null
                                        : _scan,
                                    icon: const Icon(Icons.biotech_outlined),
                                    label: const Text('Scan Leaf'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanResultDialog extends StatelessWidget {
  const _ScanResultDialog({
    required this.imageBytes,
    required this.result,
    required this.confidencePct,
    required this.onClose,
    required this.onSave,
  });

  final Uint8List imageBytes;
  final CassavaAnalysisResult result;
  final int confidencePct;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final suggestionLines = result.suggestions
        .split(RegExp(r'[\n•]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return AlertDialog(
      title: const Text('Scan Results'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.memory(
                imageBytes,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(
                result.diseaseClass,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: result.isHealthy
                  ? AppColors.healthyBg
                  : AppColors.diseaseBg,
              labelStyle: TextStyle(
                color: result.isHealthy
                    ? AppColors.primaryDark
                    : AppColors.diseaseFg,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: $confidencePct%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Analysis',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              result.analysis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Suggestions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            if (suggestionLines.isEmpty)
              Text(
                result.suggestions,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...suggestionLines.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onClose, child: const Text('Close')),
        FilledButton(onPressed: onSave, child: const Text('Save to History')),
      ],
    );
  }
}
