import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

/// Two-tap score entry for a team match. Result (win / draw) follows the score.
class MatchScoreScreen extends ConsumerStatefulWidget {
  const MatchScoreScreen({super.key, required this.competitionId, required this.matchId});
  final String competitionId;
  final String matchId;

  @override
  ConsumerState<MatchScoreScreen> createState() => _MatchScoreScreenState();
}

class _MatchScoreScreenState extends ConsumerState<MatchScoreScreen> {
  late int home, away;
  final note = TextEditingController();
  String scorer = '';

  @override
  void initState() {
    super.initState();
    final m = _match();
    home = m.homeScore ?? 0;
    away = m.awayScore ?? 0;
    scorer = m.topScorer ?? '';
  }

  Competition _comp() => ref.read(competitionsProvider.notifier).byId(widget.competitionId);
  Match _match() => _comp().matches.firstWhere((m) => m.id == widget.matchId);

  @override
  Widget build(BuildContext context) {
    final c = _comp();
    final m = _match();
    final h = c.team(m.home), a = c.team(m.away);
    final result = home == away ? 'Draw' : '${(home > away ? h : a).name} win';
    final step = c.sport == 'Basketball' ? 2 : 1;

    Widget side(Team t, int v, ValueChanged<int> on, String k) => Expanded(
          child: Column(children: [
            Container(height: 8, width: 64, decoration: BoxDecoration(color: t.house == null ? C.support : houseInfo(t.house!).color, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 10),
            Text(t.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('$v', key: Key('score-$k'), style: T.number(64)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              RoundIconButton(Icons.remove_rounded, key: Key('$k-minus'), tooltip: 'Minus', onTap: v > 0 ? () => on((v - step).clamp(0, 999)) : null),
              const SizedBox(width: 12),
              RoundIconButton(Icons.add_rounded, key: Key('$k-plus'), tooltip: 'Plus', filled: true, onTap: () => on(v + step)),
            ]),
          ]),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          StackBar(title: 'Round ${m.round}, ${m.venue}', subtitle: '${c.name} · ${m.slot}'),
          Expanded(
            child: ListView(padding: pagePad, children: [
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    side(h, home, (v) => setState(() => home = v), 'home'),
                    const Padding(padding: EdgeInsets.only(top: 76), child: Text('VS', style: TextStyle(fontFamily: kDisplay, fontSize: 18, color: C.text3))),
                    side(a, away, (v) => setState(() => away = v), 'away'),
                  ]),
                  const SizedBox(height: 18),
                  Pill(result, key: const Key('result-label'), icon: home == away ? Icons.drag_handle_rounded : Icons.emoji_events_outlined),
                ]),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.star_outline_rounded, color: C.accentFill),
                    const SizedBox(width: 8),
                    const Text('Top scorer', style: T.label),
                    const Spacer(),
                    Text(scorer.isEmpty ? 'Not set' : scorer, style: T.caption),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: note,
                    style: T.body,
                    decoration: InputDecoration(
                      hintText: 'Add a note (court, injury, MVP)',
                      hintStyle: const TextStyle(fontFamily: kBody, color: C.text3),
                      filled: true,
                      fillColor: C.surface,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(children: [
              PrimaryButton(
                key: const Key('save-score'),
                label: 'Save result',
                icon: Icons.check_rounded,
                onPressed: () {
                  ref.read(competitionsProvider.notifier).score(c.id, m.id, home, away, scorer: scorer.isEmpty ? null : scorer);
                  Navigator.of(context).pop();
                  toast(context, '$result $home-$away, table updated');
                },
              ),
              const SizedBox(height: 6),
              const Text('League table updates instantly', style: TextStyle(fontFamily: kBody, fontSize: 13, color: C.text2)),
            ]),
          ),
        ]),
      ),
    );
  }
}
