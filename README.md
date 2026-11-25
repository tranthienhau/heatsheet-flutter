# Heatsheet

School sports event manager built with Flutter and Riverpod: run a full sports day, house competitions and inter-school tournaments from one app, with results that update the house standings and the big-screen board the moment they are entered.

## Demo

![Android demo](screenshots/demo.gif)

Captured on an Android emulator. The same codebase builds for iOS.

## What it shows

- **Live event dashboard**: event progress (14 of 32 events, 44%), events running now, results waiting to be entered, live house totals and what is up next, designed for one-tap use during a busy event.
- **Fast result entry**: an official times a 100m heat lane by lane (simulated stopwatch, nudge by 0.01 s, did-not-start), lanes re-rank as each time comes in, house points for placing (10, 8, 6, 4, 2, 1) preview before submit. Field events use the same screen with distances, longest first.
- **Points that move everything**: submitting a heat updates house totals, medal table, event progress and the display board straight away.
- **Fixtures and scheduling**: round robin fixtures generated with the circle method (15 matches over 5 rounds for 6 teams, no team on two courts at once), regenerate while keeping played results, long-press and drop to swap two matches, a live league table (win 3, draw 1, loss 0, then difference).
- **Competition formats**: a one-screen wizard for round robin, league (home and away), knockout (seeded bracket) and groups + knockout, with third-place match, points and team count.
- **Knockout bracket**: quarter-finals to the final with connector lines, penalties when level, winners advance on save, third-place match fills from the semi-final losers.
- **Sports day schedule**: four stations on a timeline, with clash detection (a student entered in two events at the same time on different stations) and a one-tap fix that moves the later event to the first free slot.
- **Standings and display mode**: podium, points bars, medal table, league tables, and a full-screen leaderboard for a projector or hall TV with the latest result, what is next and announcements.
- **Houses, classes and teams**: four houses with captains and rosters, year groups and house teams.
- **Roles and permissions**: school admin, organiser, official and spectator. Spectators see live scores only; staff access is toggled per permission.
- A first-run state for a school with no events yet.

## Screenshots

| Welcome | Role | Live dashboard | Enter times |
|---|---|---|---|
| ![Welcome](screenshots/01-welcome.png) | ![Role](screenshots/02-role-select.png) | ![Live dashboard](screenshots/03-live-dashboard.png) | ![Enter times](screenshots/04-enter-times.png) |

| Events | New competition | Schedule | Fixtures |
|---|---|---|---|
| ![Events](screenshots/05-events.png) | ![New competition](screenshots/06-create-competition.png) | ![Schedule](screenshots/07-schedule.png) | ![Fixtures](screenshots/08-fixtures.png) |

| Match score | Bracket | Standings | Display mode |
|---|---|---|---|
| ![Match score](screenshots/09-match-score.png) | ![Bracket](screenshots/10-bracket.png) | ![Standings](screenshots/11-standings.png) | ![Display mode](screenshots/12-display-mode.png) |

| Houses and teams | Staff and roles | First run |
|---|---|---|
| ![Houses and teams](screenshots/13-houses-teams.png) | ![Staff and roles](screenshots/14-staff-roles.png) | ![First run](screenshots/15-live-empty.png) |

## App flow

```mermaid
flowchart TD
    W[Welcome] -->|Sign in| R[Pick role: admin, organiser, official]
    W -->|View as spectator| L
    R --> L[Live dashboard: progress, running, results waiting, house totals]
    L -->|Running heat or Enter| E[Enter results: lane times or distances]
    E -->|Submit| P[(Results)]
    P --> H[House points + medals]
    H --> S[Standings: podium, medal table, leagues]
    S --> D[Display mode on a big screen]
    L -. tabs .- EV[Events]
    EV -->|New event| C[New competition: format, points, teams]
    C -->|Generate fixtures| F[Fixtures + league table]
    EV --> B[Knockout bracket]
    F -->|Tap a match| M[Match score] --> F
    B -->|Tap a tie| BS[Score + penalties] --> B
    L -. tabs .- SC[Schedule: stations timeline]
    SC -->|Clash found| X[Fix: move to first free slot] --> SC
    L -. tabs .- MO[More: houses, rosters, staff roles]
```

## Architecture

```
lib/
  domain/models.dart     houses, athletes, events, entries, matches, ties, roles
  domain/engine.dart     ranking + placing points, house totals, round robin, league table,
                         knockout seeding + advance, clash detection + fix
  data/sample_data.dart  one school's sports day, a basketball league, a football cup, staff
  state/providers.dart   Riverpod Notifiers: role, sports day, standings, competitions, cup, staff
  core/                  design tokens from the Stitch design, shared controls
  features/              live, results, events, fixtures, bracket, schedule, standings, more, shell
design/                  the Stitch screens (HTML + PNG) the UI was built from
integration_test/        screenshot walk and paced demo used for the media above
```

- **State**: Riverpod 3 `Notifier`s. Standings, progress and clashes are derived providers, so one submitted heat updates the dashboard, the podium and the display board with no extra wiring.
- **Logic is plain Dart** in `domain/engine.dart` and unit tested (`test/engine_test.dart`): ties share a place and its points, DNS scores nothing, odd team counts get byes, no team plays twice in a slot, the clash fix never creates a new clash.
- **Mock data only**: no backend, no accounts. The stopwatch and tape reads are simulated behind a tap.
- **Design**: Varela Round for UI, Sniglet for titles and numbers, bubble pink on a tinted near-white, house colours always shown with the house name.

## Run

```sh
flutter pub get
flutter run            # Android emulator or iOS simulator
flutter test           # engine unit tests + widget tests for every key screen
```

Built with Flutter 3.35 and Dart 3.9.
