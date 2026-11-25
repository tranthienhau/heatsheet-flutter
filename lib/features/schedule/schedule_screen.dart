import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../fixtures/fixtures_screen.dart';

const _stations = ['Track', 'Pit A', 'Field 2', 'Throws'];
const _from = 9 * 60, _to = 12 * 60 + 30;
const _pxPerMin = 2.2;

/// Sports-day timetable by station, with clash warnings and a one-tap fix.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int view = 0;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(sportsDayProvider);
    final clashes = ref.watch(clashesProvider);
    final role = ref.watch(roleProvider) ?? Role.spectator;
    final comps = ref.watch(competitionsProvider);
    final clashIds = {for (final c in clashes) ...[c.first.id, c.second.id]};

    return ListView(key: const Key('schedule-list'), padding: EdgeInsets.zero, children: [
      const TabHeader('Schedule', subtitle: 'Fri 28 Nov · 4 stations'),
      Padding(
        padding: pagePad,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Segmented(items: const ['By station', 'By time'], index: view, keyPrefix: 'sched-view', onChanged: (i) => setState(() => view = i)),
          const SizedBox(height: 16),
          if (clashes.isNotEmpty)
            Container(
              key: const Key('clash-card'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.warningTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.warning, width: 1.5)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: C.warning, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${clashes.length} clash${clashes.length > 1 ? 'es' : ''}', style: const TextStyle(fontFamily: kBody, fontSize: 16, fontWeight: FontWeight.w700, color: C.warning)),
                    const SizedBox(height: 2),
                    Text(
                      '${SampleData.athletes.firstWhere((a) => a.id == clashes.first.athleteId).name} is in ${clashes.first.first.name} and ${clashes.first.second.name} at ${clock(clashes.first.at)}',
                      style: const TextStyle(fontFamily: kBody, fontSize: 14, color: C.warning, height: 1.35),
                    ),
                  ]),
                ),
                if (role.canEditFixtures)
                  TextButton(
                    key: const Key('fix-clash'),
                    style: TextButton.styleFrom(foregroundColor: C.warning, minimumSize: const Size(48, 48)),
                    onPressed: () {
                      final c = clashes.first;
                      ref.read(sportsDayProvider.notifier).fix(c);
                      final moved = ref.read(sportsDayProvider).firstWhere((e) => e.id == c.second.id);
                      toast(context, '${moved.name} moved to ${clock(moved.start)}, no clashes left');
                    },
                    child: const Text('Fix', style: TextStyle(fontFamily: kBody, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
              ]),
            )
          else
            Container(
              key: const Key('no-clash'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.successTint, borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.check_circle_rounded, color: C.success),
                SizedBox(width: 10),
                Expanded(child: Text('No clashes: every student is in one place at a time', style: TextStyle(fontFamily: kBody, fontSize: 15, color: C.success))),
              ]),
            ),
          const SizedBox(height: 16),
          if (view == 0) _Grid(events: events, clashIds: clashIds) else _ByTime(events: events, clashIds: clashIds),
          SectionHeader('Tournaments', count: comps.length),
          for (final c in comps) ...[
            AppCard(
              key: Key('open-fixtures-${c.id}'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FixturesScreen(competitionId: c.id))),
              child: Row(children: [
                const Icon(Icons.sports_basketball_outlined, color: C.accentFill),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('${c.matches.length} fixtures · ${c.matches.where((m) => m.played).length} played', style: T.caption),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: C.borderStrong),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          if (role.canEditFixtures)
            SecondaryButton(
              key: const Key('auto-arrange'),
              label: 'Auto-arrange the day',
              icon: Icons.auto_fix_high_outlined,
              onPressed: () {
                ref.read(sportsDayProvider.notifier).arrange();
                toast(context, 'Schedule arranged around every clash');
              },
            ),
        ]),
      ),
    ]);
  }
}

Color _fill(SportsEvent e) => switch (e.status) {
      EventStatus.done => C.successTint,
      EventStatus.running => C.accentTint,
      EventStatus.waiting => const Color(0xFFEDE8FE),
      EventStatus.upcoming => C.surfaceAlt,
    };

class _Grid extends StatelessWidget {
  const _Grid({required this.events, required this.clashIds});
  final List<SportsEvent> events;
  final Set<String> clashIds;

  @override
  Widget build(BuildContext context) {
    const h = (_to - _from) * _pxPerMin;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 44),
          for (final s in _stations) Expanded(child: Text(s, textAlign: TextAlign.center, style: T.label.copyWith(fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: h,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 44,
              child: Stack(children: [
                for (var m = _from; m <= _to - 30; m += 30)
                  Positioned(top: (m - _from) * _pxPerMin - 1, child: Text(clock(m), style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.text3))),
              ]),
            ),
            for (final s in _stations)
              Expanded(
                child: Stack(children: [
                  for (var m = _from; m <= _to; m += 30)
                    Positioned(top: (m - _from) * _pxPerMin, left: 0, right: 0, child: Container(height: 1, color: C.border)),
                  for (final e in events.where((e) => e.station == s && e.end > _from && e.start < _to))
                    AnimatedPositioned(
                      key: Key('block-${e.id}'),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      top: (e.start - _from) * _pxPerMin,
                      left: 2,
                      right: 2,
                      height: e.duration * _pxPerMin - 2,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 4, 2),
                        decoration: BoxDecoration(
                          color: _fill(e),
                          borderRadius: BorderRadius.circular(8),
                          border: clashIds.contains(e.id) ? Border.all(color: C.warning, width: 2) : null,
                        ),
                        child: Text('${e.name.replaceAll('Year ', 'Y')} ${clock(e.start)}',
                            overflow: TextOverflow.fade, style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.ink, height: 1.15)),
                      ),
                    ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _ByTime extends StatelessWidget {
  const _ByTime({required this.events, required this.clashIds});
  final List<SportsEvent> events;
  final Set<String> clashIds;

  @override
  Widget build(BuildContext context) {
    final sorted = [...events]..sort((a, b) => a.start.compareTo(b.start));
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: [
        for (var i = 0; i < sorted.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: C.border),
          SizedBox(
            height: 60,
            child: Row(children: [
              SizedBox(width: 52, child: Text(clock(sorted[i].start), style: T.number(16))),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sorted[i].name, style: T.label, overflow: TextOverflow.ellipsis),
                  Text('${sorted[i].station} · ${statusLabel(sorted[i].status)}', style: T.caption),
                ]),
              ),
              if (clashIds.contains(sorted[i].id)) const Icon(Icons.warning_amber_rounded, color: C.warning),
            ]),
          ),
        ],
      ]),
    );
  }
}
