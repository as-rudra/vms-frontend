import 'package:flutter/material.dart';
import '../navigation/app_route.dart';
import '../theme/app_theme.dart';

/// Responsive desktop-first application shell that wraps authenticated screens.
///
/// Uses a persistent sidebar on desktop screens (>= 960px) and a modal drawer
/// on tablet/mobile screens (< 960px).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentDestination,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.currentUserEmail,
    required this.onSelectDestination,
    required this.onLogout,
    required this.child,
  });

  final AppDestination currentDestination;
  final String pageTitle;
  final String pageSubtitle;
  final String currentUserEmail;
  final ValueChanged<AppDestination> onSelectDestination;
  final VoidCallback onLogout;
  final Widget child;

  static const double _desktopBreakpoint = 960;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 264,
                  child: _SidebarContent(
                    currentDestination: currentDestination,
                    currentUserEmail: currentUserEmail,
                    onSelectDestination: onSelectDestination,
                    onLogout: onLogout,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _TopHeaderBar(
                        title: pageTitle,
                        subtitle: pageSubtitle,
                        currentUserEmail: currentUserEmail,
                      ),
                      const Divider(height: 1),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(pageTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: IconButton(
                  tooltip: 'Sign Out',
                  onPressed: onLogout,
                  icon: const Icon(
                    Icons.logout_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: AppColors.surface,
            child: _SidebarContent(
              currentDestination: currentDestination,
              currentUserEmail: currentUserEmail,
              onSelectDestination: (destination) {
                Navigator.of(context).pop();
                onSelectDestination(destination);
              },
              onLogout: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
          ),
          body: child,
        );
      },
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.currentDestination,
    required this.currentUserEmail,
    required this.onSelectDestination,
    required this.onLogout,
  });

  final AppDestination currentDestination;
  final String currentUserEmail;
  final ValueChanged<AppDestination> onSelectDestination;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VMS Admin',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fleet Operations Portal',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                'NAVIGATION',
                style: textTheme.labelSmall,
              ),
            ),
            ...AppDestination.values.map((destination) {
              final isSelected = destination == currentDestination;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 2,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primarySoft,
                  selectedColor: colorScheme.primary,
                  iconColor: AppColors.textSecondary,
                  textColor: AppColors.textSecondary,
                  leading: Icon(
                    isSelected ? destination.selectedIcon : destination.icon,
                    size: 20,
                  ),
                  title: Text(
                    destination.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  onTap: () => onSelectDestination(destination),
                ),
              );
            }),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fleet Administrator',
                              style: textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentUserEmail,
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_outlined, size: 18),
                    label: const Text('Sign Out'),
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

class _TopHeaderBar extends StatelessWidget {
  const _TopHeaderBar({
    required this.title,
    required this.subtitle,
    required this.currentUserEmail,
  });

  final String title;
  final String subtitle;
  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.science_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Mock Data Mode',
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
