# Heatsheet - Source Brief

## Title

Heatsheet - school sports day and tournament manager

## Description

Heatsheet replaces spreadsheets and paper score sheets for school sport. An organiser or PE teacher sees the whole sports day on one dashboard (what is running, what is waiting for results, live house totals), officials enter lane times or distances at their station in a few taps, and every submitted result moves the house standings, the medal table and a full-screen leaderboard for the hall screen. The same app generates fixtures for round robin and league competitions, seeds knockout brackets, and catches scheduling clashes where a student is entered in two places at once.

## Store links

Not yet published (portfolio proof of concept). Source: https://github.com/tranthienhau/heatsheet-flutter

## Platform

Android demo, iOS-ready codebase (Flutter). The phone app is the organiser's and official's tool at the field; the same Flutter code can target a responsive web build for laptops and tablets.

## Category

Education / Sports / Event management

## Features

- Live event dashboard: progress (14 of 32 events), events running now, results waiting, house totals, up next
- Result entry for track (times, fastest first) and field (distances, longest first), simulated stopwatch per lane, did-not-start, placing points 10, 8, 6, 4, 2, 1
- House points, medal table and event progress update the moment results are submitted
- Round robin and league fixture generation (circle method, byes for odd counts, no team on two courts at once), regenerate keeping played results, drag a match onto another to swap slots
- League table with configurable win / draw / loss points
- New competition wizard: round robin, league, knockout, groups + knockout, third-place match, points, team count
- Knockout bracket with penalties, winners advance, third-place match from the semi-final losers
- Sports day schedule by station or by time, clash detection and one-tap fix, auto-arrange
- Standings: podium, points comparison, medal table, league tables
- Display mode: full-screen house leaderboard, latest result, next event, announcement
- Houses with captains and rosters, year groups, house teams
- Roles: school admin, organiser, official, spectator; per-permission staff toggles; spectators are read-only
- First-run state for a school with no events

## Tech stack

- Flutter 3.35, Dart 3.9, Riverpod 3 (`Notifier`, derived `Provider`s)
- Plain Dart domain engine with unit tests; widget tests for every key screen at phone size
- `integration_test` + `flutter drive` for real screenshots and the demo GIF, captured on GitHub Actions (Android emulator)
- Design first in Google Stitch (15 screens), fonts Varela Round and Sniglet bundled
- Stack reason: the job does not name a stack, so the owner's default (Flutter + Riverpod) was used; one Flutter codebase also covers the responsive web, tablet and phone targets the job asks for.

## Industry

Education (K-12 schools, PE departments, inter-school sport)

## Metrics

Unpublished POC, no usage metrics. Demo data: one school, 4 houses (835 students in the house totals, 26 named students in the rosters), 12 sports-day events on 4 stations, a 6-team league (15 fixtures), an 8-school knockout cup, 5 staff accounts.

## Research notes

- Verified in code and tests: ranking with shared places, house points and medals, round robin generation (15 matches for 6 teams, 30 home and away, byes for odd counts), league table, knockout seeding and advance with penalties, clash detection and fix.
- Mocked: sign-in, stopwatch and tape reads (tap to record), staff invites, CSV import, persistence (in-memory only), real-time sync between devices.
- Scope: the job describes a multi-role web platform. This POC proves the core loop on one device: enter a result, standings and the big screen move. Next steps: backend with real-time sync (for example Firestore or Supabase), responsive web build with a laptop layout and a true landscape TV board, multi-school accounts for the platform administrator, swimming gala lane sheets, drag-and-drop on the station timeline, export of results.
- Design QA on the real Android capture: 97/100, no Critical or Major findings. Known minor issues: the empty time placeholder ('--.--') renders as rounded bars in the display font; 10-15 minute blocks on the station timeline clip their names; the match screen's top scorer row is read-only; horizontal chip rows cut at the screen edge without a fade.
- Capture: GitHub Actions Android emulator (Pixel 6, API 34); 15 screenshots and a 36 s demo GIF from integration tests.
