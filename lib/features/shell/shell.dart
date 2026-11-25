import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../events/events_screen.dart';
import '../live/live_screen.dart';
import '../more/more_screen.dart';
import '../schedule/schedule_screen.dart';
import '../standings/standings_screen.dart';
import '../../state/providers.dart';

const _tabs = [
  ('Live', Icons.sensors_rounded, 'tab-live'),
  ('Events', Icons.calendar_month_outlined, 'tab-events'),
  ('Schedule', Icons.schedule_rounded, 'tab-schedule'),
  ('Standings', Icons.emoji_events_outlined, 'tab-standings'),
  ('More', Icons.menu_rounded, 'tab-more'),
];

/// Five-tab shell: Live, Events, Schedule, Standings, More (same bar on every tab screen).
class Shell extends ConsumerWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(tabProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: i, children: const [LiveScreen(), EventsScreen(), ScheduleScreen(), StandingsScreen(), MoreScreen()]),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: C.surface, border: Border(top: BorderSide(color: C.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(children: [
              for (var t = 0; t < _tabs.length; t++)
                Expanded(
                  child: InkWell(
                    key: Key(_tabs[t].$3),
                    onTap: () => ref.read(tabProvider.notifier).go(t),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 56,
                        height: 30,
                        decoration: BoxDecoration(color: t == i ? C.accentTint : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                        child: Icon(_tabs[t].$2, color: t == i ? C.accentFill : C.text2, size: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(_tabs[t].$1,
                          style: TextStyle(fontFamily: kBody, fontSize: 12, fontWeight: t == i ? FontWeight.w700 : FontWeight.w500, color: t == i ? C.accentFill : C.text2)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
