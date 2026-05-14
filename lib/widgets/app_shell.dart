import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';

enum AppDestination { dashboard, newScan, history }

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.destination,
    required this.child,
  });

  final AppDestination destination;
  final Widget child;

  static const double sidebarWidth = 280;
  static const double wideBreakpoint = 768;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= wideBreakpoint;
        if (wide) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Sidebar(
                  destination: destination,
                  width: sidebarWidth,
                  isDrawer: false,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_titleFor(destination)),
          ),
          drawer: Drawer(
            width: sidebarWidth,
            child: _Sidebar(
              destination: destination,
              width: sidebarWidth,
              isDrawer: true,
            ),
          ),
          body: child,
        );
      },
    );
  }

  static String _titleFor(AppDestination d) {
    return switch (d) {
      AppDestination.dashboard => 'Dashboard',
      AppDestination.newScan => 'New Scan',
      AppDestination.history => 'Scan History',
    };
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destination,
    required this.width,
    required this.isDrawer,
  });

  final AppDestination destination;
  final double width;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🌿 CassavaGuard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 24),
                _NavTile(
                  icon: Icons.home_outlined,
                  label: 'Dashboard',
                  selected: destination == AppDestination.dashboard,
                  onTap: () => _go(context, '/dashboard'),
                ),
                _NavTile(
                  icon: Icons.photo_camera_outlined,
                  label: 'New Scan',
                  selected: destination == AppDestination.newScan,
                  onTap: () => _go(context, '/new-scan'),
                ),
                _NavTile(
                  icon: Icons.history,
                  label: 'History',
                  selected: destination == AppDestination.history,
                  onTap: () => _go(context, '/history'),
                ),
                const Spacer(),
                const Divider(),
                _NavTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  selected: false,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    if (isDrawer) Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    if (isDrawer) Navigator.pop(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging out...')),
      );
      await FirebaseAuthService.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    }
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFF0F7F0) : Colors.transparent;
    final fg = selected ? AppColors.primary : AppColors.textLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
