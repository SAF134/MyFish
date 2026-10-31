import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Item bottom nav.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Bottom nav pill (gaya referensi): kontainer putih membulat dengan
/// bayangan `md`; tab aktif = pill biru gradien + label, tab lain = ikon bulat.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.pillAll,
              border: Border.all(color: AppColors.border, width: 1.0),
              boxShadow: AppShadows.md,
            ),
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              label: 'Navigasi utama',
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      flex: i == currentIndex ? 2 : 1,
                      child: _NavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        index: i,
                        total: items.length,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.index,
    required this.total,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final int index;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: AppColors.onPrimary);

    return Semantics(
      button: true,
      selected: selected,
      label: '${item.label}, tab ${index + 1} dari $total',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppDurations.medium,
            curve: Curves.easeOutCubic,
            height: AppSizes.minTouch + AppSpacing.xs,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              color: selected ? null : AppColors.surfaceAlt,
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: selected
                    ? AppColors.primaryDark.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: selected ? AppShadows.primaryButton : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: AppSizes.icon,
                  color: selected ? AppColors.onPrimary : AppColors.textMuted,
                ),
                if (selected) ...[
                  const SizedBox(width: AppSpacing.xs + 2),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
