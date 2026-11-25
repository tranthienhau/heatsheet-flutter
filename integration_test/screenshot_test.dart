import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heatsheet/app.dart';
import 'package:integration_test/integration_test.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (t) async {
    await t.pumpWidget(const ProviderScope(child: HeatsheetApp()));
    await binding.convertFlutterSurfaceToImage();
    await waitFor(t, find.byKey(const Key('sign-in')), timeoutMs: 60000);
    await pumpFor(t, 1500);

    Future<void> shot(String name) async {
      await pumpFor(t, 1400);
      await binding.takeScreenshot(name);
    }

    await shot('01-welcome');
    await tapKey(t, 'sign-in');
    await shot('02-role-select');
    await tapKey(t, 'continue-role');
    await shot('03-live-dashboard');
    await tapKey(t, 'event-g7-100');
    for (var i = 0; i < 4; i++) {
      await tapKey(t, 'record-lane', settleMs: 300);
    }
    await t.drag(find.byKey(const Key('results-list')), const Offset(0, 1500));
    await shot('04-enter-times');
    await tapKey(t, 'record-lane', settleMs: 300);
    await tapKey(t, 'submit-results', settleMs: 2600); // let the toast go before the next shot
    await tapKey(t, 'tab-events');
    await shot('05-events');
    await tapKey(t, 'new-event');
    await shot('06-create-competition');
    await tapKey(t, 'close-create');
    await tapKey(t, 'tab-schedule');
    await shot('07-schedule');
    await tapKey(t, 'open-fixtures-y9-basket');
    await shot('08-fixtures');
    await tapKey(t, 'match-r1m2');
    await tapKey(t, 'home-plus', settleMs: 300);
    await tapKey(t, 'home-plus', settleMs: 300);
    await tapKey(t, 'away-plus', settleMs: 300);
    await shot('09-match-score');
    await tapKey(t, 'save-score', settleMs: 2600);
    await tapKey(t, 'back');
    await tapKey(t, 'tab-events');
    await tapKey(t, 'event-row-cup');
    await shot('10-bracket');
    await tapKey(t, 'back');
    await tapKey(t, 'tab-standings');
    await shot('11-standings');
    await tapKey(t, 'open-display');
    await shot('12-display-mode');
    await tapKey(t, 'close-display');
    await tapKey(t, 'tab-more');
    await tapKey(t, 'open-houses');
    await shot('13-houses-teams');
    await tapKey(t, 'back');
    await tapKey(t, 'open-roles');
    await shot('14-staff-roles');
    await tapKey(t, 'back');
    await tapKey(t, 'first-run', settleMs: 1200);
    await shot('15-live-empty');
  });
}
