import 'models.dart';

/// Points for placing on sports day: 1st 10, 2nd 8, 3rd 6, 4th 4, 5th 2, 6th 1.
const placingPoints = [10, 8, 6, 4, 2, 1];

/// Ranks an event's entries. Track: lowest time wins. Field: longest mark wins.
/// Equal marks share a position and its points; DNS and empty marks get no position.
List<Placing> rankEvent(SportsEvent e) {
  final scored = e.entries.where((x) => !x.dns && x.mark != null).toList()
    ..sort((a, b) => e.lowerIsBetter ? a.mark!.compareTo(b.mark!) : b.mark!.compareTo(a.mark!));
  final out = <Placing>[];
  for (var i = 0; i < scored.length; i++) {
    final tiedWithPrev = i > 0 && scored[i].mark == scored[i - 1].mark;
    final pos = tiedWithPrev ? out[i - 1].position! : i + 1;
    out.add(Placing(scored[i], pos, pos <= placingPoints.length ? placingPoints[pos - 1] : 0));
  }
  for (final x in e.entries.where((x) => x.dns || x.mark == null)) {
    out.add(Placing(x, null, 0));
  }
  return out;
}

class HouseScore {
  HouseScore(this.house, this.points, this.gold, this.silver, this.bronze);
  final HouseId house;
  int points;
  int gold, silver, bronze;
  int get medals => gold + silver + bronze;
}

/// House totals = points carried from events finished before the app's data window plus
/// every event with entered results.
List<HouseScore> houseStandings(
  Map<HouseId, List<int>> carried, // points, gold, silver, bronze
  List<SportsEvent> events,
  HouseId Function(String athleteId) houseOf,
) {
  final s = {
    for (final h in HouseId.values)
      h: HouseScore(h, carried[h]?[0] ?? 0, carried[h]?[1] ?? 0, carried[h]?[2] ?? 0, carried[h]?[3] ?? 0),
  };
  for (final e in events.where((e) => e.status == EventStatus.done)) {
    for (final p in rankEvent(e)) {
      if (p.position == null) continue;
      final hs = s[houseOf(p.entry.athleteId)]!;
      hs.points += p.points;
      if (p.position == 1) hs.gold++;
      if (p.position == 2) hs.silver++;
      if (p.position == 3) hs.bronze++;
    }
  }
  final list = s.values.toList()..sort((a, b) => b.points.compareTo(a.points));
  return list;
}

/// Circle-method round robin: every team meets every other team once (twice for a league
/// with home and away). An odd team count adds a bye.
List<Match> roundRobin(List<Team> teams, {bool homeAndAway = false, List<String> days = const [], List<String> venues = const ['Court 1', 'Court 2'], String time = '13:10'}) {
  final ids = teams.map((t) => t.id).toList();
  if (ids.length.isOdd) ids.add('_bye');
  final n = ids.length;
  final rounds = <List<(String, String)>>[];
  var rot = List<String>.from(ids);
  for (var r = 0; r < n - 1; r++) {
    final pairs = <(String, String)>[];
    for (var i = 0; i < n ~/ 2; i++) {
      final a = rot[i], b = rot[n - 1 - i];
      if (a == '_bye' || b == '_bye') continue;
      pairs.add(r.isEven ? (a, b) : (b, a));
    }
    rounds.add(pairs);
    rot = [rot.first, rot.last, ...rot.sublist(1, n - 1)];
  }
  if (homeAndAway) rounds.addAll([for (final r in List.of(rounds)) [for (final (a, b) in r) (b, a)]]);
  final out = <Match>[];
  for (var r = 0; r < rounds.length; r++) {
    final day = days.isEmpty ? 'Round ${r + 1}' : days[r % days.length];
    for (var i = 0; i < rounds[r].length; i++) {
      final (a, b) = rounds[r][i];
      final wave = i ~/ venues.length;
      final t = _addMinutes(time, wave * 30);
      out.add(Match(id: 'r${r + 1}m${i + 1}', round: r + 1, home: a, away: b, slot: '$day, $t', venue: venues[i % venues.length]));
    }
  }
  return out;
}

String _addMinutes(String hhmm, int add) {
  final p = hhmm.split(':');
  return clock(int.parse(p[0]) * 60 + int.parse(p[1]) + add);
}

/// True when no team plays twice in the same slot (two courts at once).
bool hasTeamClash(List<Match> matches) {
  final seen = <String>{};
  for (final m in matches) {
    if (!seen.add('${m.slot}|${m.home}') || !seen.add('${m.slot}|${m.away}')) return true;
  }
  return false;
}

/// League table: points, then goal/points difference, then scored.
List<TableRow> leagueTable(Competition c) {
  final rows = {for (final t in c.teams) t.id: TableRow(t)};
  for (final m in c.matches.where((m) => m.played)) {
    final h = rows[m.home], a = rows[m.away];
    if (h == null || a == null) continue;
    h.played++;
    a.played++;
    h.scored += m.homeScore!;
    h.conceded += m.awayScore!;
    a.scored += m.awayScore!;
    a.conceded += m.homeScore!;
    if (m.homeScore! > m.awayScore!) {
      h.won++;
      a.lost++;
      h.points += c.points.win;
      a.points += c.points.loss;
    } else if (m.homeScore! < m.awayScore!) {
      a.won++;
      h.lost++;
      a.points += c.points.win;
      h.points += c.points.loss;
    } else {
      h.drawn++;
      a.drawn++;
      h.points += c.points.draw;
      a.points += c.points.draw;
    }
  }
  return rows.values.toList()
    ..sort((x, y) {
      final p = y.points.compareTo(x.points);
      if (p != 0) return p;
      final d = y.diff.compareTo(x.diff);
      return d != 0 ? d : y.scored.compareTo(x.scored);
    });
}

/// Knockout rounds from a seeded list: 1 v 8, 4 v 5, 2 v 7, 3 v 6 for eight teams.
/// Later rounds start empty and fill from winners via [advance].
List<List<Tie>> knockout(List<String> seeds) {
  var size = 1;
  while (size < seeds.length) {
    size *= 2;
  }
  final order = _seedOrder(size);
  final first = <Tie>[];
  for (var i = 0; i < size; i += 2) {
    final a = order[i] <= seeds.length ? seeds[order[i] - 1] : null;
    final b = order[i + 1] <= seeds.length ? seeds[order[i + 1] - 1] : null;
    first.add(Tie(a, b));
  }
  final rounds = [first];
  while (rounds.last.length > 1) {
    rounds.add(List.generate(rounds.last.length ~/ 2, (_) => const Tie(null, null)));
  }
  return rounds;
}

List<int> _seedOrder(int size) {
  var o = [1, 2];
  while (o.length < size) {
    final n = o.length * 2 + 1;
    o = [for (final s in o) ...[s, n - s]];
  }
  return o;
}

/// Pushes winners into the next round, keeping slots and venues already set there.
List<List<Tie>> advance(List<List<Tie>> rounds) {
  final out = [List<Tie>.from(rounds.first)];
  for (var r = 1; r < rounds.length; r++) {
    final prev = out[r - 1];
    out.add([
      for (var i = 0; i < rounds[r].length; i++)
        () {
          final t = rounds[r][i];
          return Tie(prev[i * 2].winner ?? t.a, prev[i * 2 + 1].winner ?? t.b,
              scoreA: t.scoreA, scoreB: t.scoreB, pensA: t.pensA, pensB: t.pensB, slot: t.slot, venue: t.venue);
        }(),
    ]);
  }
  return out;
}

bool _overlaps(SportsEvent a, SportsEvent b) => a.start < b.end && b.start < a.end;

/// Every athlete entered in two overlapping events on different stations.
List<Clash> findClashes(List<SportsEvent> events) {
  final out = <Clash>[];
  final open = events.where((e) => e.status != EventStatus.done).toList()..sort((a, b) => a.start.compareTo(b.start));
  for (var i = 0; i < open.length; i++) {
    for (var j = i + 1; j < open.length; j++) {
      final a = open[i], b = open[j];
      if (a.station == b.station || !_overlaps(a, b)) continue;
      final shared = a.entries.map((e) => e.athleteId).toSet().intersection(b.entries.map((e) => e.athleteId).toSet());
      for (final id in shared) {
        out.add(Clash(id, a, b, b.start > a.start ? b.start : a.start));
      }
    }
  }
  return out;
}

/// Moves the later event of a clash to the first free slot on its own station after the
/// earlier event ends, in 10-minute steps, without creating a new clash.
List<SportsEvent> fixClash(List<SportsEvent> events, Clash c) {
  final target = c.second;
  var start = c.first.end;
  start = ((start + 9) ~/ 10) * 10;
  for (var guard = 0; guard < 40; guard++, start += 10) {
    final moved = target.copyWith(start: start);
    final others = events.where((e) => e.id != target.id).toList();
    final stationFree = others.where((e) => e.station == target.station).every((e) => !_overlaps(e, moved));
    if (!stationFree) continue;
    final next = [for (final e in events) e.id == target.id ? moved : e];
    if (findClashes(next).where((x) => x.first.id == target.id || x.second.id == target.id).isEmpty) return next;
  }
  return events;
}

/// Resolves every clash in turn.
List<SportsEvent> autoArrange(List<SportsEvent> events) {
  var cur = events;
  for (var i = 0; i < 10; i++) {
    final c = findClashes(cur);
    if (c.isEmpty) break;
    cur = fixClash(cur, c.first);
  }
  return cur;
}
