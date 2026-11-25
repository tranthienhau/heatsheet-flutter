import 'package:flutter_test/flutter_test.dart';
import 'package:heatsheet/data/sample_data.dart';
import 'package:heatsheet/domain/engine.dart';
import 'package:heatsheet/domain/models.dart';

void main() {
  test('opening board reads 186 / 174 / 162 / 151 with the design medal table', () {
    final s = houseStandings(SampleData.carried(), SampleData.events(), SampleData.houseOf);
    expect(s.map((x) => x.points), [186, 174, 162, 151]);
    expect(s.first.house, HouseId.falcons);
    expect([s.first.gold, s.first.silver, s.first.bronze], [6, 4, 3]);
  });

  test('track ranks fastest first, DNS gets no points, ties share a place', () {
    const e = SportsEvent(id: 'x', name: 'x', station: 'Track', start: 0, duration: 10, kind: EventKind.track, status: EventStatus.done, entries: [
      Entry(1, 'a', mark: 13.42),
      Entry(2, 'b', mark: 13.10),
      Entry(3, 'c', mark: 13.42),
      Entry(4, 'd', dns: true),
    ]);
    final r = rankEvent(e);
    expect(r.map((p) => p.entry.athleteId), ['b', 'a', 'c', 'd']);
    expect(r.map((p) => p.position), [1, 2, 2, null]);
    expect(r.map((p) => p.points), [10, 8, 8, 0]);
  });

  test('field ranks longest first', () {
    const e = SportsEvent(id: 'x', name: 'x', station: 'Pit', start: 0, duration: 10, kind: EventKind.field, status: EventStatus.done, entries: [
      Entry(1, 'a', mark: 4.1),
      Entry(2, 'b', mark: 5.0),
    ]);
    expect(rankEvent(e).first.entry.athleteId, 'b');
  });

  test('round robin of 6 teams: 15 matches over 5 rounds, every pair once, no team twice in a slot', () {
    final m = roundRobin(SampleData.basketTeams, days: SampleData.leagueDays);
    expect(m.length, 15);
    expect(m.map((x) => x.round).toSet().length, 5);
    final pairs = m.map((x) => ([x.home, x.away]..sort()).join('-')).toSet();
    expect(pairs.length, 15);
    expect(hasTeamClash(m), isFalse);
    expect(roundRobin(SampleData.basketTeams, homeAndAway: true).length, 30);
  });

  test('odd team count gets byes', () {
    final m = roundRobin(SampleData.basketTeams.take(5).toList());
    expect(m.length, 10);
  });

  test('league table: 3 for a win, 1 for a draw', () {
    var c = SampleData.basketball();
    final rows = leagueTable(c);
    expect(rows.first.team.id, c.matches.first.home);
    expect(rows.first.points, 3);
    c = c.withMatches([for (final m in c.matches) m.id == c.matches[1].id ? m.withScore(30, 30) : m]);
    expect(leagueTable(c).where((r) => r.drawn == 1).length, 2);
  });

  test('knockout seeds 8 teams into 4 ties and advances winners incl. penalties', () {
    final k = knockout(SampleData.cupSchools);
    expect(k.map((r) => r.length), [4, 2, 1]);
    final cup = SampleData.footballCup();
    expect(cup[1][0].a, 'Westbrook');
    expect(cup[1][0].b, 'Oakfield');
    expect(cup[1][1].a, 'Kingsway');
    expect(cup[2][0].a, isNull);
  });

  test('Noah Kim clash is found and the fix moves long jump after the 100m', () {
    final ev = SampleData.events();
    final c = findClashes(ev);
    expect(c.length, 1);
    expect(c.first.athleteId, 'noah');
    final fixed = fixClash(ev, c.first);
    expect(findClashes(fixed), isEmpty);
    final lj = fixed.firstWhere((e) => e.id == 'b7-lj');
    expect(lj.start, greaterThanOrEqualTo(SampleData.t(11, 30)));
  });
}
