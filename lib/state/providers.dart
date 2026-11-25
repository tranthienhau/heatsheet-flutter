import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_data.dart';
import '../domain/engine.dart';
import '../domain/models.dart';

/// Signed-in role. Null until the role screen is passed.
class RoleNotifier extends Notifier<Role?> {
  @override
  Role? build() => null;
  void set(Role? r) => state = r;
}

final roleProvider = NotifierProvider<RoleNotifier, Role?>(RoleNotifier.new);

class TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

final tabProvider = NotifierProvider<TabNotifier, int>(TabNotifier.new);

/// The sports day: every event, its station, slot and entered marks.
class SportsDayNotifier extends Notifier<List<SportsEvent>> {
  @override
  List<SportsEvent> build() => SampleData.events();

  SportsEvent byId(String id) => state.firstWhere((e) => e.id == id);

  void _put(SportsEvent e) => state = [for (final x in state) x.id == e.id ? e : x];

  void setMark(String eventId, int lane, double? mark) {
    final e = byId(eventId);
    _put(e.copyWith(entries: [
      for (final x in e.entries) x.lane == lane ? Entry(lane, x.athleteId, mark: mark) : x,
    ]));
  }

  void setDns(String eventId, int lane) {
    final e = byId(eventId);
    _put(e.copyWith(entries: [
      for (final x in e.entries) x.lane == lane ? Entry(lane, x.athleteId, dns: true) : x,
    ]));
  }

  /// Simulated stopwatch / tape: the official taps Stop for a lane, the read comes from mock data.
  void record(String eventId, int lane) {
    final read = SampleData.stopwatch[eventId]?[lane];
    if (read == null) {
      setDns(eventId, lane);
    } else {
      setMark(eventId, lane, read);
    }
  }

  void nudge(String eventId, int lane, double by) {
    final x = byId(eventId).entries.firstWhere((x) => x.lane == lane);
    if (x.mark == null) return;
    setMark(eventId, lane, double.parse((x.mark! + by).toStringAsFixed(2)));
  }

  /// Confirms the results: the event is done and its points count towards the houses.
  void submit(String eventId) {
    _put(byId(eventId).copyWith(status: EventStatus.done));
    ref.read(lastResultProvider.notifier).set(eventId);
  }

  void fix(Clash c) => state = fixClash(state, c);
  void arrange() => state = autoArrange(state);
  void clear() => state = const [];
  void reset() => state = SampleData.events();
}

final sportsDayProvider = NotifierProvider<SportsDayNotifier, List<SportsEvent>>(SportsDayNotifier.new);

class LastResultNotifier extends Notifier<String> {
  @override
  String build() => 'g9-100';
  void set(String id) => state = id;
}

final lastResultProvider = NotifierProvider<LastResultNotifier, String>(LastResultNotifier.new);

final _carried = SampleData.carried();

/// Live house table, recomputed whenever a result is submitted.
final standingsProvider = Provider<List<HouseScore>>((ref) {
  final events = ref.watch(sportsDayProvider);
  if (events.isEmpty) return [for (final h in HouseId.values) HouseScore(h, 0, 0, 0, 0)];
  return houseStandings(_carried, events, SampleData.houseOf);
});

final clashesProvider = Provider<List<Clash>>((ref) => findClashes(ref.watch(sportsDayProvider)));

class Progress {
  const Progress(this.done, this.total, this.running, this.waiting);
  final int done, total, running, waiting;
  double get ratio => total == 0 ? 0 : done / total;
}

final progressProvider = Provider<Progress>((ref) {
  final e = ref.watch(sportsDayProvider);
  if (e.isEmpty) return const Progress(0, 0, 0, 0);
  int count(EventStatus s) => e.where((x) => x.status == s).length;
  return Progress(SampleData.carriedDone + count(EventStatus.done), SampleData.totalEvents, count(EventStatus.running), count(EventStatus.waiting));
});

/// Team competitions (leagues, round robins, knockouts made in the app).
class CompetitionsNotifier extends Notifier<List<Competition>> {
  @override
  List<Competition> build() => [SampleData.basketball()];

  Competition byId(String id) => state.firstWhere((c) => c.id == id);

  void _put(Competition c) => state = [for (final x in state) x.id == c.id ? c : x];

  void score(String compId, String matchId, int h, int a, {String? scorer}) {
    final c = byId(compId);
    _put(c.withMatches([for (final m in c.matches) m.id == matchId ? m.withScore(h, a, scorer: scorer) : m]));
  }

  /// Manual edit: swaps the slot and court of two matches (drag a match onto another).
  void swap(String compId, String a, String b) {
    final c = byId(compId);
    final ma = c.matches.firstWhere((m) => m.id == a), mb = c.matches.firstWhere((m) => m.id == b);
    _put(c.withMatches([
      for (final m in c.matches)
        m.id == a
            ? m.moved(slot: mb.slot, venue: mb.venue)
            : m.id == b
                ? m.moved(slot: ma.slot, venue: ma.venue)
                : m,
    ]));
  }

  /// Rebuilds unplayed fixtures from the format, keeping played results.
  void regenerate(String compId) {
    final c = byId(compId);
    final played = {for (final m in c.matches.where((m) => m.played)) '${m.home}-${m.away}': m};
    final fresh = roundRobin(c.teams, homeAndAway: c.format == CompetitionFormat.league, days: SampleData.leagueDays);
    _put(c.withMatches([for (final m in fresh) played['${m.home}-${m.away}'] ?? m]));
  }

  void add(Competition c) => state = [c, ...state];
}

final competitionsProvider = NotifierProvider<CompetitionsNotifier, List<Competition>>(CompetitionsNotifier.new);

/// Inter-school football cup, knockout with a third-place match.
class CupNotifier extends Notifier<List<List<Tie>>> {
  @override
  List<List<Tie>> build() => SampleData.footballCup();

  void score(int round, int index, int a, int b, {int? pensA, int? pensB}) {
    final rounds = [for (final r in state) List<Tie>.from(r)];
    final t = rounds[round][index];
    rounds[round][index] = Tie(t.a, t.b, scoreA: a, scoreB: b, pensA: pensA, pensB: pensB, slot: t.slot, venue: t.venue);
    state = advance(rounds);
  }
}

final cupProvider = NotifierProvider<CupNotifier, List<List<Tie>>>(CupNotifier.new);

class StaffNotifier extends Notifier<List<StaffMember>> {
  @override
  List<StaffMember> build() => SampleData.staff;
  void toggle(String name, String key) => state = [for (final s in state) s.name == name ? s.toggle(key) : s];
}

final staffProvider = NotifierProvider<StaffNotifier, List<StaffMember>>(StaffNotifier.new);
