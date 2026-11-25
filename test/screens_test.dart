import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heatsheet/app.dart';

/// Loads the bundled fonts so text measures like on a device (overflows show up here).
Future<void> loadFonts() async {
  for (final (family, files) in [
    ('VarelaRound', ['assets/fonts/VarelaRound-Regular.ttf']),
    ('Sniglet', ['assets/fonts/Sniglet-Regular.ttf', 'assets/fonts/Sniglet-ExtraBold.ttf']),
  ]) {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(rootBundle.load(f));
    }
    await l.load();
  }
}

Future<void> boot(WidgetTester t) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 2.75;
  addTearDown(t.view.reset);
  await loadFonts();
  await t.pumpWidget(const ProviderScope(child: HeatsheetApp()));
  await t.pumpAndSettle();
}

Future<void> tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}

Future<void> signIn(WidgetTester t) async {
  await tap(t, 'sign-in');
  await tap(t, 'continue-role');
}

void main() {
  testWidgets('welcome and role screens render', (t) async {
    await boot(t);
    expect(find.text('Run sports day\nfrom one screen.'), findsOneWidget);
    await tap(t, 'sign-in');
    expect(find.text('How are you helping today?'), findsOneWidget);
    await tap(t, 'role-official');
    expect(find.text('Continue as Official'), findsOneWidget);
  });

  testWidgets('live dashboard shows progress, houses and waiting results', (t) async {
    await boot(t);
    await signIn(t);
    expect(find.text('44%'), findsOneWidget);
    expect(find.text('186'), findsWidgets);
    expect(find.byKey(const Key('enter-b8-200')), findsOneWidget);
  });

  testWidgets('entering heat times ranks lanes and updates house totals', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'event-g7-100');
    for (var i = 0; i < 4; i++) {
      await tap(t, 'record-lane');
    }
    await tap(t, 'record-lane'); // lane 5 has no read: did not start
    expect(find.text('DNS'), findsWidgets);
    await tap(t, 'submit-results');
    // Falcons get 1st (+10) on top of 186.
    expect(find.text('196'), findsWidgets);
    expect(find.text('47%'), findsOneWidget);
  });

  testWidgets('waiting 200m results submit from the dashboard', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'enter-b8-200');
    expect(find.text('27.12s'), findsOneWidget);
    await tap(t, 'submit-results');
    expect(find.byKey(const Key('enter-b8-200')), findsNothing);
  });

  testWidgets('events list and create competition generate fixtures', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-events');
    expect(find.text('Year 9 Basketball League'), findsOneWidget);
    await tap(t, 'new-event');
    await tap(t, 'format-knockout');
    await tap(t, 'teams-8');
    await tap(t, 'generate');
    expect(find.textContaining('Fixtures generated: 4 matches'), findsOneWidget);
  });

  testWidgets('fixtures, score entry and table', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-schedule');
    await tap(t, 'open-fixtures-y9-basket');
    expect(find.textContaining('15 matches over 5 rounds, no clashes'), findsOneWidget);
    await tap(t, 'match-r1m2');
    await tap(t, 'home-plus');
    await tap(t, 'home-plus');
    await tap(t, 'save-score');
    await tap(t, 'fx-tab-1');
    expect(find.text('Pts'), findsOneWidget);
  });

  testWidgets('schedule clash is fixed in one tap', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-schedule');
    expect(find.byKey(const Key('clash-card')), findsOneWidget);
    await tap(t, 'fix-clash');
    expect(find.byKey(const Key('no-clash')), findsOneWidget);
    await tap(t, 'sched-view-1');
  });

  testWidgets('bracket renders with winners advanced', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-events');
    await tap(t, 'event-row-cup');
    expect(find.text('Oakfield'), findsWidgets);
    await tap(t, 'tie-1-0');
    await tap(t, 'tie-a-plus');
    await tap(t, 'save-tie');
    expect(find.text('Westbrook'), findsWidgets);
  });

  testWidgets('standings, medals and display mode', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-standings');
    expect(find.byKey(const Key('podium-falcons')), findsOneWidget);
    await tap(t, 'st-tab-1');
    expect(find.byKey(const Key('medal-table')), findsOneWidget);
    await tap(t, 'st-tab-2');
    await tap(t, 'st-tab-0');
    await tap(t, 'open-display');
    expect(find.byKey(const Key('display-falcons')), findsOneWidget);
    await tap(t, 'close-display');
  });

  testWidgets('more: houses, roles and first-run view', (t) async {
    await boot(t);
    await signIn(t);
    await tap(t, 'tab-more');
    await tap(t, 'open-houses');
    expect(find.text('Falcons roster'), findsOneWidget);
    await tap(t, 'house-seg-1');
    await tap(t, 'house-seg-2');
    await tap(t, 'back');
    await tap(t, 'open-roles');
    await tap(t, 'perm-Manage users');
    await tap(t, 'back');
    await tap(t, 'first-run');
    expect(find.text('No events yet'), findsOneWidget);
  });

  testWidgets('spectators cannot enter results', (t) async {
    await boot(t);
    await tap(t, 'spectator');
    expect(find.byKey(const Key('enter-b8-200')), findsNothing);
    await tap(t, 'tab-events');
    expect(find.byKey(const Key('new-event')), findsNothing);
  });
}
