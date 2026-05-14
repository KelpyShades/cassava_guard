import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/scan_models.dart';
import '../services/firebase_auth_service.dart';
import '../state/scan_history_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.dashboard,
      child: LayoutBuilder(
        builder: (context, c) {
          final pad = c.maxWidth >= AppShell.wideBreakpoint ? 32.0 : 16.0;
          return ValueListenableBuilder<List<HistoryRow>>(
            valueListenable: scanHistory,
            builder: (context, rows, _) {
              final total = rows.length;
              final healthy = rows.where((r) => r.healthy).length;
              final issues = total - healthy;
              final stats = <_StatData>[
                _StatData('$total', 'Saved scans', Icons.eco_outlined),
                _StatData('$healthy', 'Healthy', Icons.check_circle_outline),
                _StatData('$issues', 'Issues flagged', Icons.warning_amber_rounded),
              ];
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
                          'Welcome back, ${FirebaseAuthService.userDisplayLabel(FirebaseAuth.instance.currentUser)} 👋',
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
                          'Protect your cassava crops with AI-powered disease detection',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 520;
                    if (narrow) {
                      return Column(
                        children: [
                          for (final s in stats) ...[
                            _StatCard(data: s),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          Expanded(child: _StatCard(data: stats[i])),
                          if (i != stats.length - 1) const SizedBox(width: 12),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/new-scan'),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Start New Scan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'How CassavaGuard Works',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _InfoStep(
                          icon: Icons.cloud_upload_outlined,
                          text: 'Upload a cassava leaf image',
                        ),
                        const _InfoStep(
                          icon: Icons.smart_toy_outlined,
                          text: 'The AI analyzes the leaf',
                        ),
                        const _InfoStep(
                          icon: Icons.memory,
                          text: 'The system predicts the disease',
                        ),
                        const _InfoStep(
                          icon: Icons.medical_services_outlined,
                          text: 'You receive treatment recommendations',
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

class _StatData {
  const _StatData(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
                ),
              ),
              child: Icon(data.icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    data.label,
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

class _InfoStep extends StatelessWidget {
  const _InfoStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
