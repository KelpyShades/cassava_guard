import 'package:flutter/material.dart';

import '../models/scan_models.dart';
import '../state/scan_history_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.history,
      child: LayoutBuilder(
        builder: (context, c) {
          final pad = c.maxWidth >= AppShell.wideBreakpoint ? 32.0 : 16.0;
          return ValueListenableBuilder<List<HistoryRow>>(
            valueListenable: scanHistory,
            builder: (context, rows, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan History',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'View all your previous cassava leaf scans',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            value: '${rows.length}',
                            label: 'Saved scans',
                            icon: Icons.show_chart_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryStat(
                            value:
                                '${rows.where((r) => r.healthy).length}',
                            label: 'Healthy (saved)',
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Scans',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Filters coming soon'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.filter_list, size: 18),
                                  label: const Text('Filter'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  AppColors.background,
                                ),
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Image')),
                                  DataColumn(label: Text('Disease')),
                                  DataColumn(label: Text('Confidence')),
                                  DataColumn(label: Text('Outcome')),

                                ],
                                rows: [
                                  for (final r in rows)
                                    DataRow(
                                      cells: [
                                        DataCell(Text(r.dateLabel)),
                                        const DataCell(
                                          Icon(Icons.image_outlined,
                                              color: AppColors.primary),
                                        ),
                                        DataCell(
                                          _DiseaseChip(
                                            label: r.diseaseLabel,
                                            healthy: r.healthy,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            r.confidencePct != null
                                                ? '${r.confidencePct}%'
                                                : '—',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        DataCell(
                                          _ScanOutcomeLabel(healthy: r.healthy),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
                ),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiseaseChip extends StatelessWidget {
  const _DiseaseChip({required this.label, required this.healthy});

  final String label;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      padding: EdgeInsets.zero,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: healthy ? AppColors.primaryDark : AppColors.diseaseFg,
      ),
      backgroundColor: healthy ? AppColors.healthyBg : AppColors.diseaseBg,
      side: BorderSide.none,
    );
  }
}

class _ScanOutcomeLabel extends StatelessWidget {
  const _ScanOutcomeLabel({required this.healthy});

  final bool healthy;

  @override
  Widget build(BuildContext context) {
    final color = healthy ? AppColors.primaryLight : AppColors.diseaseFg;
    final text = healthy ? 'Healthy' : 'Issue flagged';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
