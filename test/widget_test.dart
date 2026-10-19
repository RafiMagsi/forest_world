import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forest_os/main.dart';
import 'package:forest_os/models/forest_discovery.dart';
import 'package:forest_os/screens/forest_home_screen.dart';
import 'package:forest_os/widgets/discovery_marker.dart';
import 'package:forest_os/widgets/forest_bottom_nav.dart';
import 'package:forest_os/widgets/forest_pulse_card.dart';

/// Phone-sized surface so the portrait layouts are tested as users see them.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Videos and markers animate forever, so advance time explicitly instead
/// of using pumpAndSettle.
Future<void> pumpFrames(WidgetTester tester, [int ms = 1500]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  testWidgets('home screen shows the living forest hero', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ForestOSApp());
    await pumpFrames(tester);

    expect(find.byType(ForestHomeScreen), findsOneWidget);
    expect(find.text('FORESTOS'), findsOneWidget);
    expect(find.textContaining('A quieter'), findsOneWidget);
    expect(find.text('Enter the Forest'), findsOneWidget);
    expect(find.byType(ForestPulseCard), findsOneWidget);
    expect(find.text('128'), findsOneWidget); // count-up lands on sample data
    expect(find.byType(ForestBottomNav), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('Enter the Forest opens the aerial Explore screen',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ForestOSApp());
    await pumpFrames(tester);

    await tester.tap(find.text('Enter the Forest'));
    await pumpFrames(tester, 1200);

    expect(find.text('Whispering Woods'), findsOneWidget);
    expect(find.text('A forest full of stories.'), findsOneWidget);
    expect(find.byType(DiscoveryMarker), findsNWidgets(3));
    expect(find.text('The Ancient Oak'), findsOneWidget);
    expect(find.text('The Hidden Stream'), findsOneWidget);
    expect(find.text('Woodland Wildlife'), findsOneWidget);
  });

  testWidgets('tapping a marker slides up its discovery card',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ForestOSApp());
    await pumpFrames(tester);

    await tester.tap(find.text('Enter the Forest'));
    await pumpFrames(tester, 1200);

    await tester.tap(find.byType(DiscoveryMarker).first);
    await pumpFrames(tester, 800);

    expect(
      find.text('A living landmark of the Whispering Woods.'),
      findsOneWidget,
    );
    expect(find.text('The Ancient Oak'), findsWidgets); // marker chip + row
  });

  testWidgets('a discovery opens its detail and can be saved',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const ForestOSApp());
    await pumpFrames(tester);

    await tester.tap(find.text('Enter the Forest'));
    await pumpFrames(tester, 1200);

    // Open the Ancient Oak detail from the DISCOVER list.
    await tester.tap(find.text('The Ancient Oak'));
    await pumpFrames(tester, 1400);

    expect(find.text('THE FOREST GIANT'), findsOneWidget);
    expect(find.text('SPECIES'), findsOneWidget);
    expect(find.text('Thriving'), findsOneWidget);
    expect(find.text('DID YOU KNOW?'), findsOneWidget);
    // The save action sits below the fold on a phone — scroll to it.
    await tester.scrollUntilVisible(
      find.text('Save Discovery'),
      240,
      scrollable: find.byType(Scrollable),
    );
    await pumpFrames(tester, 500);
    expect(find.text('Save Discovery'), findsOneWidget);

    // Save it.
    await tester.tap(find.text('Save Discovery'));
    await pumpFrames(tester, 600);
    expect(find.text('Saved to My Forest'), findsOneWidget);
    expect(SavedForestStore.instance.isSaved('ancient_oak'), isTrue);

    // Clear the confirmation snackbar so it cannot cover the button.
    final messenger = tester.state<ScaffoldMessengerState>(
      find.byType(ScaffoldMessenger),
    );
    messenger.clearSnackBars();
    await pumpFrames(tester, 800);

    // Unsave to keep the singleton store clean for other runs.
    await tester.tap(find.text('Saved to My Forest'));
    await pumpFrames(tester, 600);
    expect(find.text('Save Discovery'), findsOneWidget);
    expect(SavedForestStore.instance.isSaved('ancient_oak'), isFalse);
  });

  test('saved store toggles discoveries', () {
    final store = SavedForestStore.instance;
    final oak = ForestDiscovery.ancientOak;

    expect(store.toggle(oak), isTrue);
    expect(store.isSaved(oak.id), isTrue);
    expect(store.savedDiscoveries.map((d) => d.id), contains(oak.id));

    expect(store.toggle(oak), isFalse);
    expect(store.isSaved(oak.id), isFalse);
  });
}
