import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heatsheet/app.dart';
import 'package:integration_test/integration_test.dart';

import 'harness.dart';

/// Paced walkthrough for the demo GIF (about 30 s): sign in as the organiser, time a 100m
/// heat lane by lane, submit, watch the house standings and the big-screen board move, fix a
/// schedule clash, then score a league match.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (t) async {
    await t.pumpWidget(const ProviderScope(child: HeatsheetApp()));
    await waitFor(t, find.byKey(const Key('sign-in')), timeoutMs: 60000);
    await pumpFor(t, 1200);
    debugPrint('POC_DEMO_START');
    await pumpFor(t, 1200);
    await tapKey(t, 'sign-in', settleMs: 1100);
    await tapKey(t, 'continue-role', settleMs: 1800);
    await tapKey(t, 'event-g7-100', settleMs: 1200);
    for (var i = 0; i < 5; i++) {
      await tapKey(t, 'record-lane', settleMs: 650);
    }
    await tapKey(t, 'submit-results', settleMs: 2200);
    await tapKey(t, 'tab-standings', settleMs: 1500);
    await tapKey(t, 'open-display', settleMs: 2400);
    await tapKey(t, 'close-display', settleMs: 900);
    await tapKey(t, 'tab-schedule', settleMs: 1400);
    await tapKey(t, 'fix-clash', settleMs: 2000);
    await tapKey(t, 'open-fixtures-y9-basket', settleMs: 1400);
    await tapKey(t, 'match-r1m2', settleMs: 1000);
    await tapKey(t, 'home-plus', settleMs: 450);
    await tapKey(t, 'home-plus', settleMs: 450);
    await tapKey(t, 'save-score', settleMs: 1400);
    await tapKey(t, 'fx-tab-1', settleMs: 2000);
    debugPrint('POC_DEMO_END');
    await pumpFor(t, 500);
  });
}
