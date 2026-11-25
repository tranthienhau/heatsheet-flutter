import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../bracket/bracket_screen.dart';
import '../fixtures/fixtures_screen.dart';
import 'create_competition.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String filter = 'All';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final comps = ref.watch(competitionsProvider);
    final role = ref.watch(roleProvider) ?? Role.spectator;
    final rows = <_Row>[
      for (final c in comps)
        _Row(c.id, c.name, '${c.format.label} · ${c.teams.length} teams', c.matches.any((m) => m.played) ? 'In progress' : 'Scheduled',
            _photo(c.sport), 'Tournaments', () => FixturesScreen(competitionId: c.id)),
      _Row('cup', 'Inter-school Football Cup', 'Knockout · 8 schools · Sat 6 Dec', 'Scheduled', 'assets/images/thumb-football.jpg', 'Tournaments', () => const BracketScreen()),
      const _Row('gala', 'Swimming Gala', '18 races · Fri 12 Dec', 'Draft', 'assets/images/thumb-swimming.jpg', 'Galas', null),
      const _Row('volley', 'Volleyball House Cup', 'Groups + knockout · 4 houses', 'Completed', 'assets/images/thumb-volleyball.jpg', 'House cups', null),
    ];
    final shown = rows.where((r) => (filter == 'All' || r.group == filter) && r.name.toLowerCase().contains(query.toLowerCase())).toList();

    return Stack(children: [
      ListView(key: const Key('events-list'), padding: EdgeInsets.zero, children: [
        const TabHeader('Events'),
        Padding(
          padding: pagePad.copyWith(bottom: 110),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => setState(() => query = v),
              style: T.body,
              decoration: InputDecoration(
                hintText: 'Search events',
                hintStyle: const TextStyle(fontFamily: kBody, color: C.text3),
                prefixIcon: const Icon(Icons.search_rounded, color: C.text2),
                filled: true,
                fillColor: C.surface,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final f in const ['All', 'Sports days', 'Tournaments', 'House cups', 'Galas'])
                  Padding(padding: const EdgeInsets.only(right: 8), child: SelectChip(f, selected: f == filter, onTap: () => setState(() => filter = f))),
              ]),
            ),
            const SizedBox(height: 16),
            if (filter == 'All' || filter == 'Sports days')
              GestureDetector(
                key: const Key('featured-sports-day'),
                onTap: () => ref.read(tabProvider.notifier).go(0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 190,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/featured-relay.jpg', fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x001F0C18), Color(0xD91F0C18)]),
                        ),
                      ),
                      const Positioned(left: 16, top: 16, child: LiveBadge()),
                      const Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Sports Day 2026', style: TextStyle(fontFamily: kDisplay, fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('Today · 32 events · 4 houses', style: TextStyle(fontFamily: kBody, fontSize: 14, color: Colors.white)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            for (final r in shown) ...[
              AppCard(
                key: Key('event-row-${r.id}'),
                padding: const EdgeInsets.all(12),
                onTap: () {
                  final b = r.open;
                  if (b == null) {
                    toast(context, r.status == 'Draft' ? '${r.name} is a draft: add races to publish it' : '${r.name}: final standings are in Standings');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => b()));
                },
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(r.photo, width: 64, height: 64, fit: BoxFit.cover)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(r.meta, style: T.caption),
                      const SizedBox(height: 6),
                      statusPill(r.status),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: C.borderStrong),
                ]),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ]),
      if (role.canEditFixtures)
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            key: const Key('new-event'),
            backgroundColor: C.accentFill,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateCompetitionScreen())),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New event', style: TextStyle(fontFamily: kBody, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
    ]);
  }

  static String _photo(String sport) => switch (sport) {
        'Football' => 'assets/images/thumb-football.jpg',
        'Volleyball' => 'assets/images/thumb-volleyball.jpg',
        _ => 'assets/images/thumb-basketball.jpg',
      };
}

class _Row {
  const _Row(this.id, this.name, this.meta, this.status, this.photo, this.group, this.open);
  final String id, name, meta, status, photo, group;
  final Widget Function()? open;
}
