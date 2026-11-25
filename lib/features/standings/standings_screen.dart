import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/engine.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});
  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(standingsProvider);
    final comps = ref.watch(competitionsProvider);
    return ListView(key: const Key('standings-list'), padding: EdgeInsets.zero, children: [
      const TabHeader('Standings'),
      Padding(
        padding: pagePad,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Segmented(items: const ['Houses', 'Medals', 'Leagues'], index: tab, keyPrefix: 'st-tab', onChanged: (i) => setState(() => tab = i)),
          const SizedBox(height: 16),
          if (tab == 0) ...[
            _Podium(s),
            const SizedBox(height: 12),
            _Bars(s),
          ],
          if (tab == 1) _Medals(s),
          if (tab == 2)
            for (final c in comps) ...[
              Text(c.name, style: T.title),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  for (final (i, r) in leagueTable(c).indexed) ...[
                    if (i > 0) const Divider(height: 1, color: C.border),
                    SizedBox(
                      height: 48,
                      child: Row(children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: T.number(15, color: C.text2))),
                        Expanded(child: HouseTag(r.team.house!, style: T.label, trailing: r.team.name.split(' ').last)),
                        Text('${r.played} played  ', style: T.caption),
                        Text('${r.points} pts', style: T.number(16, color: C.accentFill)),
                      ]),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
            ],
          const SizedBox(height: 12),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [LiveBadge(), SizedBox(width: 8), Text('Updates the moment a result is submitted', style: T.caption)]),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('open-display'),
            label: 'Open display mode',
            icon: Icons.tv_outlined,
            onPressed: () => Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, _, _) => const DisplayModeScreen(),
              transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
            )),
          ),
        ]),
      ),
    ]);
  }
}

class _Podium extends StatelessWidget {
  const _Podium(this.s);
  final List<HouseScore> s;

  @override
  Widget build(BuildContext context) {
    Widget block(HouseScore h, int place, double height) {
      final house = houseInfo(h.house);
      return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(house.name, style: T.label.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${h.points}', key: Key('podium-${h.house.name}'), style: T.number(26)),
          const Text('pts', style: T.caption),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: height,
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(top: BorderSide(color: house.color, width: 8)),
              boxShadow: cardShadow,
            ),
            alignment: Alignment.center,
            child: Text('$place', style: T.number(34, color: place == 1 ? C.accentFill : C.text2)),
          ),
        ]),
      );
    }

    return Column(children: [
      SizedBox(
        height: 230,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          block(s[1], 2, 96),
          const SizedBox(width: 10),
          block(s[0], 1, 132),
          const SizedBox(width: 10),
          block(s[2], 3, 72),
        ]),
      ),
      const SizedBox(height: 10),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Text('4th', style: T.number(18, color: C.text2)),
          const SizedBox(width: 12),
          HouseTag(s[3].house, style: T.label),
          const Spacer(),
          Text('${s[3].points} pts', style: T.number(18)),
          const SizedBox(width: 10),
          Text('-${s[0].points - s[3].points}', style: T.caption),
        ]),
      ),
    ]);
  }
}

class _Bars extends StatelessWidget {
  const _Bars(this.s);
  final List<HouseScore> s;

  @override
  Widget build(BuildContext context) {
    final top = s.first.points == 0 ? 1 : s.first.points;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Points comparison', style: T.label),
        const SizedBox(height: 12),
        for (final h in s) ...[
          Row(children: [
            SizedBox(width: 92, child: HouseTag(h.house, style: T.caption)),
            Expanded(child: ProgressBar(h.points / top, color: houseInfo(h.house).color, height: 14)),
            SizedBox(width: 44, child: Text('${h.points}', textAlign: TextAlign.right, style: T.number(15))),
          ]),
          const SizedBox(height: 10),
        ],
      ]),
    );
  }
}

class _Medals extends StatelessWidget {
  const _Medals(this.s);
  final List<HouseScore> s;

  @override
  Widget build(BuildContext context) {
    final rows = [...s]..sort((a, b) {
        final g = b.gold.compareTo(a.gold);
        return g != 0 ? g : b.silver.compareTo(a.silver);
      });
    Widget medal(Color c, String l) => SizedBox(
          width: 44,
          child: Column(children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            Text(l, style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.text2)),
          ]),
        );
    return AppCard(
      key: const Key('medal-table'),
      child: Column(children: [
        Row(children: [
          const Expanded(child: Text('House', style: T.caption)),
          medal(C.gold, 'Gold'),
          medal(C.silver, 'Silver'),
          medal(C.bronze, 'Bronze'),
          const SizedBox(width: 44, child: Text('Total', textAlign: TextAlign.center, style: T.caption)),
        ]),
        for (final h in rows) ...[
          const Divider(height: 20, color: C.border),
          Row(children: [
            Expanded(child: HouseTag(h.house, style: T.label)),
            for (final v in [h.gold, h.silver, h.bronze, h.medals]) SizedBox(width: 44, child: Text('$v', textAlign: TextAlign.center, style: T.number(18))),
          ]),
        ],
      ]),
    );
  }
}

/// Full-screen leaderboard for a projector or hall TV (cast or HDMI from the device). Follows
/// every submitted result.
class DisplayModeScreen extends ConsumerStatefulWidget {
  const DisplayModeScreen({super.key});
  @override
  ConsumerState<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends ConsumerState<DisplayModeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(standingsProvider);
    final p = ref.watch(progressProvider);
    final events = ref.watch(sportsDayProvider);
    final lastId = ref.watch(lastResultProvider);
    final last = events.where((e) => e.id == lastId).firstOrNull;
    final next = (events.where((e) => e.status == EventStatus.upcoming).toList()..sort((a, b) => a.start.compareTo(b.start))).firstOrNull;
    final winner = last == null ? null : rankEvent(last).first;
    final top = s.first.points == 0 ? 1 : s.first.points;
    const white = TextStyle(fontFamily: kBody, color: Colors.white);

    Widget panel(String label, IconData icon, String title, String sub) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0x4D1F0C18), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 6), Text(label, style: white.copyWith(fontSize: 13, letterSpacing: 1))]),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontFamily: kDisplay, fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(sub, style: white.copyWith(fontSize: 15)),
          ]),
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: displayGradient),
        child: SafeArea(
          child: ListView(key: const Key('display-list'), padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
            Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/logo/icon.png', width: 40, height: 40)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Sports Day 2026', style: TextStyle(fontFamily: kDisplay, fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0x4D1F0C18), borderRadius: BorderRadius.circular(14)),
                child: Text('11:32', style: T.number(20, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Material(
                color: const Color(0x4D1F0C18),
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('close-display'),
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(width: 48, height: 48, child: Icon(Icons.close_rounded, color: Colors.white, semanticLabel: 'Close display mode')),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text('${SampleData.school} · House championship after ${p.done} of ${p.total} events', style: white.copyWith(fontSize: 14)),
            const SizedBox(height: 18),
            for (final (i, h) in s.indexed) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                decoration: BoxDecoration(color: const Color(0x4D1F0C18), borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(children: [
                    Container(width: 10, color: houseInfo(h.house).color),
                    const SizedBox(width: 14),
                    Text('${i + 1}', style: T.number(34, color: Colors.white)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(houseInfo(h.house).name, style: const TextStyle(fontFamily: kDisplay, fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 8),
                          ProgressBar(h.points / top, color: houseInfo(h.house).color, track: const Color(0x33FFFFFF), height: 8),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('${h.points}', key: Key('display-${h.house.name}'), style: T.number(40, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            if (last != null && winner != null && winner.position != null)
              panel('LATEST RESULT', Icons.flag_outlined, last.name,
                  '1st ${SampleData.athletes.firstWhere((a) => a.id == winner.entry.athleteId).name}, ${houseInfo(SampleData.houseOf(winner.entry.athleteId)).name}, ${winner.entry.mark!.toStringAsFixed(2)}${last.kind == EventKind.track ? 's' : 'm'}'),
            const SizedBox(height: 10),
            if (next != null) panel('UP NEXT', Icons.schedule_rounded, next.name, '${clock(next.start)} · ${next.station}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: const Color(0x661F0C18), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.campaign_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Announcement: ${SampleData.announcements.first}', style: white.copyWith(fontSize: 15))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
