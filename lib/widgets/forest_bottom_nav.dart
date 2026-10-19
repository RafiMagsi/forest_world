import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';

/// Translucent dark bottom navigation shared by the main screens.
/// [currentIndex] of -1 means "home" (nothing highlighted).
class ForestBottomNav extends StatelessWidget {
  const ForestBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  static const exploreIndex = 0;
  static const mapIndex = 1;
  static const myForestIndex = 2;

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ForestTheme.deepForest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ForestTheme.fern.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: 'Explore',
            active: currentIndex == exploreIndex,
            onTap: () => onSelect(exploreIndex),
          ),
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            label: 'Map',
            active: currentIndex == mapIndex,
            onTap: () => onSelect(mapIndex),
          ),
          _NavItem(
            icon: Icons.park_outlined,
            activeIcon: Icons.park_rounded,
            label: 'My Forest',
            active: currentIndex == myForestIndex,
            onTap: () => onSelect(myForestIndex),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active
            ? ForestTheme.fern.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? activeIcon : icon,
                  size: 22,
                  color: active
                      ? ForestTheme.fern
                      : ForestTheme.mistIvory.withValues(alpha: 0.65),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? ForestTheme.mistIvory
                        : ForestTheme.mistIvory.withValues(alpha: 0.6),
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
