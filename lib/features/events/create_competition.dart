import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/engine.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../fixtures/fixtures_screen.dart';

/// New competition in one screen: name, sport, format, options, points, teams, then the
/// fixtures are generated automatically.
class CreateCompetitionScreen extends ConsumerStatefulWidget {
  const CreateCompetitionScreen({super.key});
  @override
  ConsumerState<CreateCompetitionScreen> createState() => _CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState extends ConsumerState<CreateCompetitionScreen> {
  final name = TextEditingController(text: 'Year 8 Netball Cup');
  String sport = 'Netball';
  CompetitionFormat format = CompetitionFormat.roundRobin;
  bool thirdPlace = false;
  bool homeAway = false;
  int win = 3, draw = 1, loss = 0;
  int teamCount = 6;
  String? error;

  static const sports = ['Football', 'Basketball', 'Volleyball', 'Netball'];
  static const icons = {
    CompetitionFormat.roundRobin: Icons.sync_alt_rounded,
    CompetitionFormat.league: Icons.table_rows_outlined,
    CompetitionFormat.knockout: Icons.account_tree_outlined,
    CompetitionFormat.groupsKnockout: Icons.grid_view_rounded,
  };

  List<Team> _teams() {
    const order = [HouseId.falcons, HouseId.marlins, HouseId.cedars, HouseId.comets];
    return [
      for (var i = 0; i < teamCount; i++)
        Team('t$i', '${houseInfo(order[i % 4]).name} ${String.fromCharCode(65 + i ~/ 4)}', house: order[i % 4]),
    ];
  }

  void generate() {
    if (name.text.trim().length < 3) {
      setState(() => error = 'Give the competition a name');
      return;
    }
    final teams = _teams();
    final days = ['Mon 1 Dec', 'Wed 3 Dec', 'Fri 5 Dec', 'Mon 8 Dec', 'Wed 10 Dec', 'Fri 12 Dec', 'Mon 15 Dec'];
    final venues = sport == 'Football' ? ['Pitch 1', 'Pitch 2'] : ['Court 1', 'Court 2'];
    List<Match> matches;
    switch (format) {
      case CompetitionFormat.roundRobin:
      case CompetitionFormat.league:
        matches = roundRobin(teams, homeAndAway: format == CompetitionFormat.league || homeAway, days: days, venues: venues);
      case CompetitionFormat.knockout:
        final ties = knockout(teams.map((t) => t.id).toList()).first;
        matches = [
          for (var i = 0; i < ties.length; i++)
            if (ties[i].a != null && ties[i].b != null)
              Match(id: 'k$i', round: 1, home: ties[i].a!, away: ties[i].b!, slot: '${days.first}, ${clock(13 * 60 + 10 + (i ~/ 2) * 30)}', venue: venues[i % 2]),
        ];
      case CompetitionFormat.groupsKnockout:
        final a = [for (var i = 0; i < teams.length; i += 2) teams[i]];
        final b = [for (var i = 1; i < teams.length; i += 2) teams[i]];
        matches = [
          ...roundRobin(a, days: days, venues: [venues[0]]),
          ...roundRobin(b, days: days, venues: [venues[1]]).map((m) => Match(id: 'b${m.id}', round: m.round, home: m.home, away: m.away, slot: m.slot, venue: m.venue)),
        ];
    }
    final c = Competition(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      name: name.text.trim(),
      sport: sport,
      format: format,
      teams: teams,
      matches: matches,
      points: Points(win: win, draw: draw, loss: loss),
      thirdPlace: thirdPlace,
    );
    ref.read(competitionsProvider.notifier).add(c);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => FixturesScreen(competitionId: c.id, justGenerated: true)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const StackBar(title: 'New competition', subtitle: SampleData.school, close: true, backKey: 'close-create'),
          Expanded(
            child: ListView(key: const Key('create-list'), padding: pagePad, children: [
              const Text('Name', style: T.label),
              const SizedBox(height: 8),
              TextField(
                key: const Key('comp-name'),
                controller: name,
                style: T.body,
                onChanged: (_) => setState(() => error = null),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: C.surface,
                  errorText: error,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.danger)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.danger, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Sport', style: T.label),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in sports) SelectChip(s, key: Key('sport-$s'), selected: s == sport, onTap: () => setState(() => sport = s)),
              ]),
              const SectionHeader('Format'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  for (final f in CompetitionFormat.values)
                    AppCard(
                      key: Key('format-${f.name}'),
                      border: f == format ? C.accentFill : null,
                      color: f == format ? C.accentTint : C.surface,
                      padding: const EdgeInsets.all(14),
                      onTap: () => setState(() => format = f),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(icons[f], color: C.accentFill, size: 26),
                          const Spacer(),
                          if (f == format) const Icon(Icons.check_circle_rounded, color: C.accentFill),
                        ]),
                        const Spacer(),
                        Text(f.label, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(f.hint, style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.text2, height: 1.3)),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  _toggle('Third-place match', thirdPlace, (v) => setState(() => thirdPlace = v)),
                  const Divider(height: 1, color: C.border),
                  _toggle('Home and away', homeAway, (v) => setState(() => homeAway = v)),
                ]),
              ),
              const SectionHeader('Points'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(children: [
                  _stepper('Win', win, (v) => setState(() => win = v)),
                  _stepper('Draw', draw, (v) => setState(() => draw = v)),
                  _stepper('Loss', loss, (v) => setState(() => loss = v)),
                ]),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Row(children: [
                  const Icon(Icons.groups_outlined, color: C.accentFill),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Teams: $teamCount house teams', style: T.label)),
                  for (final n in const [4, 6, 8])
                    Padding(padding: const EdgeInsets.only(left: 6), child: SelectChip('$n', key: Key('teams-$n'), selected: n == teamCount, onTap: () => setState(() => teamCount = n))),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton(key: const Key('generate'), label: 'Generate fixtures', icon: Icons.auto_awesome_motion_outlined, onPressed: generate),
          ),
        ]),
      ),
    );
  }

  Widget _toggle(String label, bool v, ValueChanged<bool> on) => SizedBox(
        height: 56,
        child: Row(children: [Expanded(child: Text(label, style: T.body)), Switch(value: v, onChanged: on)]),
      );

  Widget _stepper(String label, int v, ValueChanged<int> on) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: T.body)),
          RoundIconButton(Icons.remove_rounded, size: 44, tooltip: 'Less', onTap: v > 0 ? () => on(v - 1) : null),
          SizedBox(width: 40, child: Text('$v', textAlign: TextAlign.center, style: T.number(22))),
          RoundIconButton(Icons.add_rounded, size: 44, tooltip: 'More', onTap: () => on(v + 1)),
        ]),
      );
}
