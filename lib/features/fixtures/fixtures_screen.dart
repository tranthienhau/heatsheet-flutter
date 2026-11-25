import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/engine.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import 'match_score.dart';

/// Auto-generated fixtures with manual edits (long-press a match and drop it on another to
/// swap their slots), and the live table.
class FixturesScreen extends ConsumerStatefulWidget {
  const FixturesScreen({super.key, required this.competitionId, this.justGenerated = false});
  final String competitionId;
  final bool justGenerated;

  @override
  ConsumerState<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends ConsumerState<FixturesScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(competitionsProvider).firstWhere((x) => x.id == widget.competitionId);
    final role = ref.watch(roleProvider) ?? Role.spectator;
    final rounds = <int, List<Match>>{};
    for (final m in c.matches) {
      rounds.putIfAbsent(m.round, () => []).add(m);
    }
    final clash = hasTeamClash(c.matches);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          StackBar(title: c.name, subtitle: '${c.format.label} · ${c.teams.length} teams · ${c.sport}'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Segmented(items: const ['Fixtures', 'Table'], index: tab, keyPrefix: 'fx-tab', onChanged: (i) => setState(() => tab = i)),
          ),
          Expanded(
            child: tab == 1
                ? _Table(c)
                : ListView(key: const Key('fixtures-list'), padding: pagePad, children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: clash ? C.warningTint : C.successTint, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Icon(clash ? Icons.warning_amber_rounded : Icons.check_circle_rounded, color: clash ? C.warning : C.success, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${widget.justGenerated ? 'Fixtures generated' : 'Fixtures'}: ${c.matches.length} matches over ${rounds.length} rounds, ${clash ? 'check clashes' : 'no clashes'}',
                            key: const Key('fixtures-banner'),
                            style: TextStyle(fontFamily: kBody, fontSize: 15, fontWeight: FontWeight.w600, color: clash ? C.warning : C.success, height: 1.35),
                          ),
                        ),
                        if (role.canEditFixtures && c.format != CompetitionFormat.knockout)
                          TextButton(
                            key: const Key('regenerate'),
                            style: TextButton.styleFrom(foregroundColor: C.accentFill, minimumSize: const Size(44, 44)),
                            onPressed: () {
                              ref.read(competitionsProvider.notifier).regenerate(c.id);
                              toast(context, 'Fixtures regenerated, played results kept');
                            },
                            child: const Text('Regenerate', style: TextStyle(fontFamily: kBody, fontWeight: FontWeight.w600)),
                          ),
                      ]),
                    ),
                    if (role.canEditFixtures)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text('Long-press a match and drop it on another to swap their times and courts.', style: T.caption),
                      ),
                    for (final r in rounds.entries) ...[
                      SectionHeader('Round ${r.key}', count: r.value.length),
                      for (final m in r.value) ...[
                        _MatchCard(c: c, m: m, editable: role.canEditFixtures),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ]),
          ),
        ]),
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({required this.c, required this.m, required this.editable});
  final Competition c;
  final Match m;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider) ?? Role.spectator;
    Widget side(String id, int? score, bool winner) {
      final t = c.team(id);
      return Row(children: [
        if (t.house != null) Container(width: 10, height: 10, decoration: BoxDecoration(color: houseInfo(t.house!).color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(t.name, style: T.label.copyWith(fontSize: 15, fontWeight: winner ? FontWeight.w800 : FontWeight.w500))),
        if (score != null) Text('$score', style: T.number(20, color: winner ? C.accentFill : C.ink)),
      ]);
    }

    final hw = m.played && m.homeScore! > m.awayScore!;
    final aw = m.played && m.awayScore! > m.homeScore!;
    final card = AppCard(
      key: Key('match-${m.id}'),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      onTap: role.canEnterResults ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchScoreScreen(competitionId: c.id, matchId: m.id))) : null,
      child: Row(children: [
        Icon(Icons.drag_indicator_rounded, color: editable ? C.borderStrong : Colors.transparent),
        const SizedBox(width: 4),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            side(m.home, m.homeScore, hw),
            const SizedBox(height: 8),
            side(m.away, m.awayScore, aw),
            const SizedBox(height: 8),
            Row(children: [
              Icon(m.played ? Icons.flag_outlined : Icons.schedule_rounded, size: 15, color: C.text2),
              const SizedBox(width: 6),
              Text(m.played ? 'Final · ${m.venue}' : '${m.slot} · ${m.venue}', style: T.caption),
            ]),
          ]),
        ),
        if (role.canEnterResults) const SizedBox(width: 44, height: 44, child: Icon(Icons.edit_outlined, color: C.accentFill, size: 22)),
      ]),
    );
    if (!editable || m.played) return card;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != m.id,
      onAcceptWithDetails: (d) {
        ref.read(competitionsProvider.notifier).swap(c.id, d.data, m.id);
        toast(context, 'Matches swapped');
      },
      builder: (context, cand, _) => LongPressDraggable<String>(
        data: m.id,
        feedback: Material(color: Colors.transparent, child: SizedBox(width: MediaQuery.of(context).size.width - 40, child: Opacity(opacity: .9, child: card))),
        childWhenDragging: Opacity(opacity: .35, child: card),
        child: cand.isEmpty ? card : DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: C.accentFill, width: 2)), child: card),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table(this.c);
  final Competition c;

  @override
  Widget build(BuildContext context) {
    final rows = leagueTable(c);
    const h = TextStyle(fontFamily: kBody, fontSize: 13, fontWeight: FontWeight.w600, color: C.text2);
    Widget cell(String s, {TextStyle style = T.label, double w = 26}) => SizedBox(width: w, child: Text(s, textAlign: TextAlign.center, style: style));
    return ListView(key: const Key('table-list'), padding: pagePad, children: [
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(children: [
          SizedBox(
            height: 40,
            child: Row(children: [
              const SizedBox(width: 24),
              const Expanded(child: Text('Team', style: h)),
              cell('P', style: h),
              cell('W', style: h),
              cell('D', style: h),
              cell('L', style: h),
              cell('+/-', style: h, w: 36),
              cell('Pts', style: h, w: 36),
            ]),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            const Divider(height: 1, color: C.border),
            SizedBox(
              height: 52,
              child: Row(children: [
                SizedBox(width: 24, child: Text('${i + 1}', style: T.number(16, color: C.text2))),
                Expanded(child: rows[i].team.house == null ? Text(rows[i].team.name, style: T.label) : HouseTag(rows[i].team.house!, style: T.label, trailing: rows[i].team.name.split(' ').last)),
                cell('${rows[i].played}'),
                cell('${rows[i].won}'),
                cell('${rows[i].drawn}'),
                cell('${rows[i].lost}'),
                cell('${rows[i].diff > 0 ? '+' : ''}${rows[i].diff}', w: 36),
                cell('${rows[i].points}', style: T.number(17, color: C.accentFill), w: 36),
              ]),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      Text('Win ${c.points.win}, draw ${c.points.draw}, loss ${c.points.loss}. Ties split on difference, then points scored.', style: T.caption),
    ]);
  }
}
