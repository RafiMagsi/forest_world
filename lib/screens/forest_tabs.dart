import 'package:flutter/material.dart';

import '../widgets/forest_bottom_nav.dart';
import 'forest_explore_screen.dart';
import 'map_screen.dart';
import 'my_forest_screen.dart';

/// Soft cross-fade with a slight settle — used when switching tabs so the
/// floating nav (a [Hero]) stays still while the scene changes beneath it.
Route<void> forestFadeRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.03, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Opens tab [index] from the screen showing tab [current] (-1 for home).
///
/// From home the tab is pushed so back returns home; between tabs the route
/// is replaced so the stack never grows.
void openForestTab(BuildContext context, int index, {required int current}) {
  if (index == current) return;
  final Widget page = switch (index) {
    ForestBottomNav.exploreIndex => const ForestExploreScreen(),
    ForestBottomNav.mapIndex => const MapScreen(),
    _ => const MyForestScreen(),
  };
  final navigator = Navigator.of(context);
  if (current < 0) {
    if (index == ForestBottomNav.exploreIndex) {
      ForestExploreScreen.push(context);
    } else {
      navigator.push(forestFadeRoute(page));
    }
  } else {
    navigator.pushReplacement(forestFadeRoute(page));
  }
}
