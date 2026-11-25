import 'package:flutter/material.dart';

/// The four school houses. Colours are data colours: always shown next to the house name.
enum HouseId { falcons, marlins, cedars, comets }

class House {
  const House(this.id, this.name, this.color, this.students, this.captain);
  final HouseId id;
  final String name;
  final Color color;
  final int students;
  final String captain;
}

class Athlete {
  const Athlete(this.id, this.name, this.form, this.year, this.house, {this.photo});
  final String id;
  final String name;
  final String form; // class, e.g. 9B
  final int year;
  final HouseId house;
  final String? photo;
}

enum EventKind { track, field, team }

enum EventStatus { upcoming, running, waiting, done }

/// One competitor slot in a sports-day event (a lane on the track, an order in a pit).
class Entry {
  const Entry(this.lane, this.athleteId, {this.mark, this.dns = false});
  final int lane;
  final String athleteId;
  final double? mark; // seconds for track, metres for field
  final bool dns;

  Entry copyWith({double? mark, bool? dns, bool clearMark = false}) =>
      Entry(lane, athleteId, mark: clearMark ? null : (mark ?? this.mark), dns: dns ?? this.dns);
}

/// An activity on the sports day, run on a station in a time slot.
class SportsEvent {
  const SportsEvent({
    required this.id,
    required this.name,
    required this.station,
    required this.start,
    required this.duration,
    required this.kind,
    required this.status,
    this.detail = '',
    this.entries = const [],
  });

  final String id;
  final String name;
  final String station;
  final int start; // minutes after midnight
  final int duration; // minutes
  final EventKind kind;
  final EventStatus status;
  final String detail;
  final List<Entry> entries;

  int get end => start + duration;
  bool get lowerIsBetter => kind == EventKind.track;

  SportsEvent copyWith({int? start, String? station, EventStatus? status, List<Entry>? entries}) => SportsEvent(
        id: id,
        name: name,
        station: station ?? this.station,
        start: start ?? this.start,
        duration: duration,
        kind: kind,
        status: status ?? this.status,
        detail: detail,
        entries: entries ?? this.entries,
      );
}

/// A ranked line of a finished (or being entered) event.
class Placing {
  const Placing(this.entry, this.position, this.points);
  final Entry entry;
  final int? position; // null for DNS / no mark
  final int points;
}

/// A team in a competition (house team, class team or a school).
class Team {
  const Team(this.id, this.name, {this.house});
  final String id;
  final String name;
  final HouseId? house;
}

class Match {
  const Match({
    required this.id,
    required this.round,
    required this.home,
    required this.away,
    required this.slot,
    required this.venue,
    this.homeScore,
    this.awayScore,
    this.topScorer,
  });

  final String id;
  final int round;
  final String home; // team id
  final String away;
  final String slot; // e.g. Mon 1 Dec, 13:10
  final String venue; // Court 1
  final int? homeScore;
  final int? awayScore;
  final String? topScorer;

  bool get played => homeScore != null && awayScore != null;

  Match withScore(int h, int a, {String? scorer}) => Match(
        id: id,
        round: round,
        home: home,
        away: away,
        slot: slot,
        venue: venue,
        homeScore: h,
        awayScore: a,
        topScorer: scorer ?? topScorer,
      );

  Match moved({String? slot, String? venue}) => Match(
        id: id,
        round: round,
        home: home,
        away: away,
        slot: slot ?? this.slot,
        venue: venue ?? this.venue,
        homeScore: homeScore,
        awayScore: awayScore,
        topScorer: topScorer,
      );
}

enum CompetitionFormat { roundRobin, league, knockout, groupsKnockout }

extension CompetitionFormatLabel on CompetitionFormat {
  String get label => switch (this) {
        CompetitionFormat.roundRobin => 'Round robin',
        CompetitionFormat.league => 'League',
        CompetitionFormat.knockout => 'Knockout',
        CompetitionFormat.groupsKnockout => 'Groups + knockout',
      };
  String get hint => switch (this) {
        CompetitionFormat.roundRobin => 'Everyone plays each other once',
        CompetitionFormat.league => 'Home and away, table decides',
        CompetitionFormat.knockout => 'Lose once and you are out',
        CompetitionFormat.groupsKnockout => 'Two groups, top two to semis',
      };
}

class Points {
  const Points({this.win = 3, this.draw = 1, this.loss = 0});
  final int win;
  final int draw;
  final int loss;
}

/// A team competition with its own teams, fixtures and scoring.
class Competition {
  const Competition({
    required this.id,
    required this.name,
    required this.sport,
    required this.format,
    required this.teams,
    required this.matches,
    this.points = const Points(),
    this.thirdPlace = false,
  });

  final String id;
  final String name;
  final String sport;
  final CompetitionFormat format;
  final List<Team> teams;
  final List<Match> matches;
  final Points points;
  final bool thirdPlace;

  Team team(String id) => teams.firstWhere((t) => t.id == id, orElse: () => Team(id, id));

  Competition withMatches(List<Match> m) => Competition(
        id: id,
        name: name,
        sport: sport,
        format: format,
        teams: teams,
        matches: m,
        points: points,
        thirdPlace: thirdPlace,
      );
}

class TableRow {
  TableRow(this.team);
  final Team team;
  int played = 0, won = 0, drawn = 0, lost = 0, scored = 0, conceded = 0, points = 0;
  int get diff => scored - conceded;
}

/// Knockout tie: two sides, a score, and penalties when level.
class Tie {
  const Tie(this.a, this.b, {this.scoreA, this.scoreB, this.pensA, this.pensB, this.slot = '', this.venue = ''});
  final String? a; // null = winner of an earlier tie, not decided yet
  final String? b;
  final int? scoreA;
  final int? scoreB;
  final int? pensA;
  final int? pensB;
  final String slot;
  final String venue;

  bool get played => scoreA != null && scoreB != null;

  String? get winner {
    if (!played || a == null || b == null) return null;
    if (scoreA! != scoreB!) return scoreA! > scoreB! ? a : b;
    if (pensA != null && pensB != null) return pensA! > pensB! ? a : b;
    return null;
  }

  String? get loser => winner == null ? null : (winner == a ? b : a);
}

enum Role { schoolAdmin, organiser, official, spectator }

extension RoleInfo on Role {
  String get label => switch (this) {
        Role.schoolAdmin => 'School admin',
        Role.organiser => 'Organiser / PE teacher',
        Role.official => 'Official',
        Role.spectator => 'Spectator',
      };
  String get blurb => switch (this) {
        Role.schoolAdmin => 'Manage houses, users and events',
        Role.organiser => 'Create events, fixtures and enter scores',
        Role.official => 'Enter times and results for assigned stations',
        Role.spectator => 'View live scores and standings',
      };
  bool get canEnterResults => this != Role.spectator;
  bool get canEditFixtures => this == Role.schoolAdmin || this == Role.organiser;
}

class StaffMember {
  const StaffMember(this.name, this.title, this.role, this.scope, this.photo, this.access);
  final String name;
  final String title;
  final Role role;
  final String scope;
  final String? photo;
  final Map<String, bool> access;

  StaffMember toggle(String key) => StaffMember(name, title, role, scope, photo, {...access, key: !(access[key] ?? false)});
}

/// One scheduling clash: the same athlete in two overlapping events on different stations.
class Clash {
  const Clash(this.athleteId, this.first, this.second, this.at);
  final String athleteId;
  final SportsEvent first;
  final SportsEvent second; // the one the fix moves
  final int at;
}

String clock(int minutes) => '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
