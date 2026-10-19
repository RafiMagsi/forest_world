import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/forest_theme.dart';
import 'glass_panel.dart';

/// Floating liquid-glass tab bar shared by the main screens.
/// [currentIndex] of -1 means "home" (no tab highlighted).
///
/// Each screen builds its own bar, so the bar is wrapped in a [Hero] to stay
/// put during page transitions, and remembers the last selected tab so the
/// sunlit indicator can glide from the previous tab to the new one.
class ForestBottomNav extends StatefulWidget {
  const ForestBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  static const exploreIndex = 0;
  static const mapIndex = 1;
  static const myForestIndex = 2;

  static const _items = [
    (
      icon: Icons.explore_outlined,
      active: Icons.explore_rounded,
      label: 'Explore',
    ),
    (icon: Icons.terrain_outlined, active: Icons.terrain_rounded, label: 'Map'),
    (icon: Icons.park_outlined, active: Icons.park_rounded, label: 'My Forest'),
  ];

  static int _lastIndex = -1;

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  State<ForestBottomNav> createState() => _ForestBottomNavState();
}

class _ForestBottomNavState extends State<ForestBottomNav>
    with SingleTickerProviderStateMixin {
  late int _from = ForestBottomNav._lastIndex;
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  @override
  void initState() {
    super.initState();
    ForestBottomNav._lastIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(ForestBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _from = oldWidget.currentIndex;
      ForestBottomNav._lastIndex = widget.currentIndex;
      _slide.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  double _x(int index) {
    final n = ForestBottomNav._items.length;
    return index < 0 ? 0 : -1 + 2 * index / (n - 1);
  }

  @override
  Widget build(BuildContext context) {
    final to = widget.currentIndex;
    return Hero(
      tag: 'forest-bottom-nav',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
        child: GlassPanel(
          radius: 999,
          tint: 0.42,
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 58,
            child: Stack(
              children: [
                // ------------------------------------------- indicator
                AnimatedBuilder(
                  animation: _slide,
                  builder: (context, _) {
                    final t = Curves.easeOutBack.transform(_slide.value);
                    final from = _from < 0 ? to : _from;
                    final x = _x(from) + (_x(to) - _x(from)) * t;
                    final visible = to >= 0;
                    final appear = _from < 0
                        ? Curves.easeOut.transform(_slide.value)
                        : 1.0;
                    return Align(
                      alignment: Alignment(x, 0),
                      child: FractionallySizedBox(
                        widthFactor: 1 / ForestBottomNav._items.length,
                        heightFactor: 1,
                        child: Opacity(
                          opacity: visible ? appear : 0,
                          child: Transform.scale(
                            scale: 0.8 + 0.2 * appear,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: ForestTheme.ctaGradient,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: ForestTheme.fern.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 18,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // ----------------------------------------------- items
                Row(
                  children: [
                    for (var i = 0; i < ForestBottomNav._items.length; i++)
                      Expanded(
                        child: _NavItem(
                          icon: ForestBottomNav._items[i].icon,
                          activeIcon: ForestBottomNav._items[i].active,
                          label: ForestBottomNav._items[i].label,
                          active: to == i,
                          onTap: () => widget.onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final color = active
        ? ForestTheme.deepForest
        : ForestTheme.mistIvory.withValues(alpha: 0.72);
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.1 : 1,
              duration: ForestTheme.medium,
              curve: Curves.easeOutBack,
              child: Icon(active ? activeIcon : icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: ForestTheme.quick,
              style: TextStyle(
                fontFamily: ForestTheme.textFamily,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
