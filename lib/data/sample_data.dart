import 'package:flutter/material.dart';

import '../domain/engine.dart';
import '../domain/models.dart';

/// Mock data for one school, Westbrook Academy, on Sports Day 2026 (Fri 28 Nov).
/// Everything is local: no backend, no accounts.
class SampleData {
  static const school = 'Westbrook Academy';
  static const eventName = 'Sports Day 2026';
  static const totalEvents = 32;

  static const houses = [
    House(HouseId.falcons, 'Falcons', Color(0xFFE5484D), 212, 'Ava Patel'),
    House(HouseId.marlins, 'Marlins', Color(0xFF3E7BFA), 208, 'Liam Brooks'),
    House(HouseId.cedars, 'Cedars', Color(0xFF2FA36B), 205, 'Tariq Vance'),
    House(HouseId.comets, 'Comets', Color(0xFFF5B300), 210, 'Sophie Turner'),
  ];

  static const athletes = [
    Athlete('ava', 'Ava Patel', '9B', 9, HouseId.falcons, photo: 'assets/images/avatar-ava-patel.jpg'),
    Athlete('noah', 'Noah Kim', '7A', 7, HouseId.falcons, photo: 'assets/images/avatar-noah-kim.jpg'),
    Athlete('mia', 'Mia Johnson', '8C', 8, HouseId.falcons, photo: 'assets/images/avatar-mia-johnson.jpg'),
    Athlete('leo', 'Leo Garcia', '10A', 10, HouseId.falcons, photo: 'assets/images/avatar-leo-garcia.jpg'),
    Athlete('grace', 'Grace Lee', '7C', 7, HouseId.falcons),
    Athlete('amy', 'Amy Ross', '7B', 7, HouseId.falcons),
    Athlete('zoe', 'Zoe Brown', '7A', 7, HouseId.marlins),
    Athlete('lily', 'Lily Chen', '7D', 7, HouseId.cedars),
    Athlete('ella', 'Ella Wright', '7B', 7, HouseId.comets),
    Athlete('omar', 'Omar Haddad', '8A', 8, HouseId.marlins),
    Athlete('jack', 'Jack Moore', '8B', 8, HouseId.cedars),
    Athlete('ryan', 'Ryan Clarke', '8D', 8, HouseId.comets),
    Athlete('sam', 'Sam Ellis', '8C', 8, HouseId.falcons),
    Athlete('isla', 'Isla Green', '10B', 10, HouseId.marlins),
    Athlete('ruby', 'Ruby Shaw', '10C', 10, HouseId.cedars),
    Athlete('maya', 'Maya Singh', '10D', 10, HouseId.comets),
    Athlete('ben', 'Ben Carter', '7C', 7, HouseId.marlins),
    Athlete('ethan', 'Ethan Hall', '7D', 7, HouseId.cedars),
    Athlete('kai', 'Kai Russo', '7B', 7, HouseId.comets),
    Athlete('nina', 'Nina Park', '9A', 9, HouseId.marlins),
    Athlete('hana', 'Hana Ito', '9C', 9, HouseId.cedars),
    Athlete('cleo', 'Cleo Ward', '9D', 9, HouseId.comets),
    Athlete('finn', 'Finn Doyle', '9B', 9, HouseId.marlins),
    Athlete('max', 'Max Webb', '9A', 9, HouseId.cedars),
    Athlete('josh', 'Josh Patel', '7A', 7, HouseId.marlins),
    Athlete('luca', 'Luca Rossi', '7D', 7, HouseId.cedars),
  ];

  static int t(int h, int m) => h * 60 + m;

  static List<SportsEvent> events() => [
        SportsEvent(
          id: 'g9-100',
          name: 'Year 9 Girls 100m',
          station: 'Track',
          start: t(9, 0),
          duration: 20,
          kind: EventKind.track,
          status: EventStatus.done,
          detail: 'Final',
          entries: const [
            Entry(1, 'nina', mark: 13.21),
            Entry(2, 'ava', mark: 12.98),
            Entry(3, 'hana', mark: 13.40),
            Entry(4, 'cleo', mark: 13.65),
          ],
        ),
        const SportsEvent(id: 'b8-200', name: 'Year 8 Boys 200m', station: 'Track', start: 600, duration: 25, kind: EventKind.track, status: EventStatus.waiting, detail: 'Final', entries: [
          Entry(1, 'omar', mark: 27.84),
          Entry(2, 'jack', mark: 28.31),
          Entry(3, 'sam', mark: 27.12),
          Entry(4, 'ryan', mark: 29.05),
        ]),
        const SportsEvent(id: 'g10-shot', name: 'Shot Put Year 10 Girls', station: 'Throws', start: 610, duration: 40, kind: EventKind.field, status: EventStatus.waiting, detail: 'Final, 3 throws', entries: [
          Entry(1, 'isla', mark: 8.42),
          Entry(2, 'ruby', mark: 9.10),
          Entry(3, 'maya', mark: 7.96),
          Entry(4, 'leo', mark: 8.75),
        ]),
        const SportsEvent(id: 'g7-100', name: 'Year 7 Girls 100m', station: 'Track', start: 640, duration: 15, kind: EventKind.track, status: EventStatus.running, detail: 'Heat 2', entries: [
          Entry(1, 'amy'),
          Entry(2, 'zoe'),
          Entry(3, 'lily'),
          Entry(4, 'ella'),
          Entry(5, 'grace'),
        ]),
        const SportsEvent(id: 'b9-lj', name: 'Long Jump Year 9 Boys', station: 'Pit A', start: 620, duration: 45, kind: EventKind.field, status: EventStatus.running, detail: 'Round 2', entries: [
          Entry(1, 'finn'),
          Entry(2, 'max'),
        ]),
        const SportsEvent(id: 'y8-tug', name: 'Tug of War Year 8', station: 'Field 2', start: 630, duration: 30, kind: EventKind.team, status: EventStatus.running, detail: 'Semi-finals'),
        const SportsEvent(id: 'y7-sack', name: 'Sack Race Year 7', station: 'Field 2', start: 660, duration: 20, kind: EventKind.team, status: EventStatus.upcoming, detail: 'All houses'),
        const SportsEvent(id: 'b7-100', name: '100m Year 7 Boys', station: 'Track', start: 680, duration: 10, kind: EventKind.track, status: EventStatus.upcoming, detail: 'Heat 3', entries: [
          Entry(1, 'noah'),
          Entry(2, 'ben'),
          Entry(3, 'ethan'),
          Entry(4, 'kai'),
        ]),
        const SportsEvent(id: 'b7-lj', name: 'Long Jump Year 7 Boys', station: 'Pit A', start: 685, duration: 30, kind: EventKind.field, status: EventStatus.upcoming, detail: 'Final', entries: [
          Entry(1, 'noah'),
          Entry(2, 'josh'),
          Entry(3, 'luca'),
        ]),
        const SportsEvent(id: 'y7-relay', name: 'Relay 4x100 Year 7', station: 'Track', start: 700, duration: 20, kind: EventKind.team, status: EventStatus.upcoming, detail: 'All houses'),
        const SportsEvent(id: 'y8-hj', name: 'High Jump Year 8', station: 'Pit A', start: 730, duration: 40, kind: EventKind.field, status: EventStatus.upcoming, detail: 'Final'),
        const SportsEvent(id: 'y10-obst', name: 'Obstacle Course Year 10', station: 'Field 2', start: 720, duration: 30, kind: EventKind.team, status: EventStatus.upcoming, detail: 'House teams'),
      ];

  /// Simulated stopwatch reads for the running heat (the official taps Stop per lane).
  static const stopwatch = {
    'g7-100': {1: 13.42, 2: 13.88, 3: 14.05, 4: 14.31},
    'b9-lj': {1: 5.12, 2: 4.87},
  };

  static HouseId houseOf(String athleteId) => athletes.firstWhere((a) => a.id == athleteId).house;

  /// Earlier events of the day (before this data window) as carried points and medals, chosen
  /// so the opening board reads Falcons 186, Marlins 174, Cedars 162, Comets 151.
  static Map<HouseId, List<int>> carried() {
    const target = {
      HouseId.falcons: [186, 6, 4, 3],
      HouseId.marlins: [174, 5, 5, 2],
      HouseId.cedars: [162, 4, 3, 6],
      HouseId.comets: [151, 3, 4, 5],
    };
    final now = houseStandings(const {}, events(), houseOf);
    return {
      for (final h in HouseId.values)
        h: () {
          final s = now.firstWhere((x) => x.house == h);
          final tg = target[h]!;
          return [tg[0] - s.points, tg[1] - s.gold, tg[2] - s.silver, tg[3] - s.bronze];
        }(),
    };
  }

  /// Events finished before the window, so progress reads 14 of 32 at the start.
  static const carriedDone = 13;

  static const basketTeams = [
    Team('fa', 'Falcons A', house: HouseId.falcons),
    Team('ma', 'Marlins A', house: HouseId.marlins),
    Team('ca', 'Cedars A', house: HouseId.cedars),
    Team('co', 'Comets A', house: HouseId.comets),
    Team('fb', 'Falcons B', house: HouseId.falcons),
    Team('cb', 'Cedars B', house: HouseId.cedars),
  ];

  static const leagueDays = ['Mon 1 Dec', 'Wed 3 Dec', 'Fri 5 Dec', 'Mon 8 Dec', 'Wed 10 Dec'];

  static Competition basketball() {
    final m = roundRobin(basketTeams, days: leagueDays);
    return Competition(
      id: 'y9-basket',
      name: 'Year 9 Basketball League',
      sport: 'Basketball',
      format: CompetitionFormat.roundRobin,
      teams: basketTeams,
      matches: [m.first.withScore(42, 38, scorer: 'Ava Patel 16 pts'), ...m.skip(1)],
    );
  }

  static const cupSchools = ['Westbrook', 'Hillside', 'Riverside', 'Oakfield', 'Kingsway', 'Lakeview', "St Mary's", 'Northgate'];

  static List<List<Tie>> footballCup() => advance([
        const [
          Tie('Westbrook', 'Hillside', scoreA: 2, scoreB: 1, slot: 'Sat 6 Dec, 10:00', venue: 'Pitch 1'),
          Tie('Riverside', 'Oakfield', scoreA: 0, scoreB: 3, slot: 'Sat 6 Dec, 10:00', venue: 'Pitch 2'),
          Tie('Kingsway', 'Lakeview', scoreA: 1, scoreB: 1, pensA: 4, pensB: 3, slot: 'Sat 6 Dec, 11:15', venue: 'Pitch 1'),
          Tie("St Mary's", 'Northgate', scoreA: 2, scoreB: 0, slot: 'Sat 6 Dec, 11:15', venue: 'Pitch 2'),
        ],
        const [
          Tie(null, null, slot: 'Sat 13:00', venue: 'Pitch 1'),
          Tie(null, null, slot: 'Sat 14:30', venue: 'Pitch 2'),
        ],
        const [Tie(null, null, slot: 'Sat 16:00', venue: 'Pitch 1')],
      ]);

  static const staff = [
    StaffMember('Mr Sam Carter', 'PE teacher', Role.organiser, 'All events', 'assets/images/staff-sam-carter.jpg',
        {'Create events': true, 'Edit fixtures': true, 'Enter results': true, 'Manage users': false}),
    StaffMember('Ms Priya Shah', 'Senior leadership', Role.schoolAdmin, 'Whole school', 'assets/images/staff-priya-shah.jpg',
        {'Create events': true, 'Edit fixtures': true, 'Enter results': true, 'Manage users': true}),
    StaffMember('Mr Tom Reed', 'Timekeeper', Role.official, 'Track + Pit A', 'assets/images/staff-tom-reed.jpg',
        {'Create events': false, 'Edit fixtures': false, 'Enter results': true, 'Manage users': false}),
    StaffMember('Ms Hannah Ortiz', 'Swimming gala judge', Role.official, 'Pool', 'assets/images/staff-hannah-ortiz.jpg',
        {'Create events': false, 'Edit fixtures': false, 'Enter results': true, 'Manage users': false}),
    StaffMember('Year 11 Helpers', '6 student marshals', Role.spectator, 'View only', null,
        {'Create events': false, 'Edit fixtures': false, 'Enter results': false, 'Manage users': false}),
  ];

  static const announcements = ['Tug of War final moved to Field 1', 'Year 7 relay teams to the call room at 11:30', 'Water station open by the pavilion'];
}

/// One card on the Events tab.
class EventSummary {
  const EventSummary(this.id, this.name, this.meta, this.status, this.photo);
  final String id;
  final String name;
  final String meta;
  final String status; // Live, Scheduled, In progress, Draft, Completed
  final String photo;
}
