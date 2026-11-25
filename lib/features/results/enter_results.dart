import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/engine.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

/// Official's result entry: times (track) or distances (field) per lane, ranked live with
/// house points, then one Submit.
class EnterResultsScreen extends ConsumerStatefulWidget {
  const EnterResultsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EnterResultsScreen> createState() => _EnterResultsScreenState();
}

class _EnterResultsScreenState extends ConsumerState<EnterResultsScreen> {
  int active = 1;

  @override
  void initState() {
    super.initState();
    final e = ref.read(sportsDayProvider.notifier).byId(widget.eventId);
    final firstOpen = e.entries.where((x) => x.mark == null && !x.dns);
    active = firstOpen.isEmpty ? e.entries.first.lane : firstOpen.first.lane;
  }

  @override
  Widget build(BuildContext context) {
    final e = ref.watch(sportsDayProvider).firstWhere((x) => x.id == widget.eventId);
    final day = ref.read(sportsDayProvider.notifier);
    final ranked = rankEvent(e);
    final unit = e.kind == EventKind.track ? 's' : 'm';
    final activeEntry = e.entries.firstWhere((x) => x.lane == active);
    final complete = e.entries.every((x) => x.dns || x.mark != null);
    final housePts = <HouseId, int>{};
    for (final p in ranked.where((p) => p.points > 0)) {
      final h = SampleData.houseOf(p.entry.athleteId);
      housePts[h] = (housePts[h] ?? 0) + p.points;
    }

    void nextLane() {
      final open = e.entries.where((x) => x.lane > active && x.mark == null && !x.dns);
      if (open.isNotEmpty) setState(() => active = open.first.lane);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          StackBar(title: e.name, subtitle: '${e.station}, ${e.detail}, Official: Mr Carter', close: true, backKey: 'close-results'),
          Expanded(
            child: ListView(key: const Key('results-list'), padding: pagePad, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), boxShadow: cardShadow, border: Border.all(color: C.accentTint, width: 2)),
                child: Column(children: [
                  Row(children: [
                    Pill('Lane $active', fg: C.ink, bg: C.surfaceAlt),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_name(activeEntry.athleteId), style: T.label, overflow: TextOverflow.ellipsis)),
                    HouseTag(SampleData.houseOf(activeEntry.athleteId)),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      activeEntry.dns ? 'DNS' : (activeEntry.mark?.toStringAsFixed(2) ?? '--.--'),
                      key: const Key('stopwatch'),
                      style: T.number(64, color: activeEntry.mark == null ? C.text3 : C.ink),
                    ),
                    const SizedBox(width: 6),
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(unit == 's' ? 'sec' : 'metres', style: T.caption)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    RoundIconButton(Icons.remove_rounded, key: const Key('nudge-minus'), tooltip: 'Minus 0.01', onTap: () => day.nudge(e.id, active, -0.01)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        key: const Key('record-lane'),
                        label: e.kind == EventKind.track ? 'Stop lane $active' : 'Measure lane $active',
                        icon: e.kind == EventKind.track ? Icons.timer_outlined : Icons.straighten_rounded,
                        height: 52,
                        onPressed: () {
                          day.record(e.id, active);
                          nextLane();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(Icons.add_rounded, key: const Key('nudge-plus'), tooltip: 'Plus 0.01', onTap: () => day.nudge(e.id, active, 0.01)),
                  ]),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('mark-dns'),
                    style: TextButton.styleFrom(foregroundColor: C.text2, minimumSize: const Size(44, 44)),
                    onPressed: () {
                      day.setDns(e.id, active);
                      nextLane();
                    },
                    child: const Text('Did not start', style: TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const SectionHeader('Lanes, ranked live'),
              for (final p in ranked) ...[
                _LaneRow(p, unit: unit, active: p.entry.lane == active, onTap: () => setState(() => active = p.entry.lane)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('House points from this event', style: T.label),
                  const SizedBox(height: 10),
                  if (housePts.isEmpty) const Text('Points appear as marks come in', style: T.caption),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final h in housePts.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: C.surfaceAlt, borderRadius: BorderRadius.circular(999)),
                        child: HouseTag(h.key, style: T.label, trailing: '+${h.value}'),
                      ),
                  ]),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(children: [
              PrimaryButton(
                key: const Key('submit-results'),
                label: 'Submit results',
                icon: Icons.check_rounded,
                onPressed: complete
                    ? () {
                        day.submit(e.id);
                        final msg = housePts.entries.map((h) => '${houseInfo(h.key).name} +${h.value}').join(', ');
                        Navigator.of(context).pop();
                        toast(context, 'Results live: $msg');
                      }
                    : null,
              ),
              const SizedBox(height: 6),
              const Text('Standings and the big screen update the moment you submit', style: TextStyle(fontFamily: kBody, fontSize: 13, color: C.text2)),
            ]),
          ),
        ]),
      ),
    );
  }
}

String _name(String id) => SampleData.athletes.firstWhere((a) => a.id == id).name;

class _LaneRow extends StatelessWidget {
  const _LaneRow(this.p, {required this.unit, required this.active, required this.onTap});
  final Placing p;
  final String unit;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = SampleData.athletes.firstWhere((x) => x.id == p.entry.athleteId);
    final pos = p.position;
    final ord = pos == null ? '' : (pos == 1 ? '1st' : pos == 2 ? '2nd' : pos == 3 ? '3rd' : '${pos}th');
    return AppCard(
      key: Key('lane-${p.entry.lane}'),
      border: active ? C.accentFill : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(children: [
        SizedBox(width: 28, child: Text('${p.entry.lane}', style: T.number(20, color: C.text2))),
        Avatar(a.photo, size: 40, initials: a.name.split(' ').map((w) => w[0]).join()),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.name, style: T.label.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            HouseTag(a.house),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(p.entry.dns ? 'DNS' : (p.entry.mark == null ? '--.--' : '${p.entry.mark!.toStringAsFixed(2)}$unit'), style: T.number(18)),
          const SizedBox(height: 4),
          if (pos != null) Text('$ord · +${p.points} pts', style: const TextStyle(fontFamily: kBody, fontSize: 13, fontWeight: FontWeight.w600, color: C.accentFill)),
        ]),
      ]),
    );
  }
}
