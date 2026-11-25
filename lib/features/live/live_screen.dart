import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../events/create_competition.dart';
import '../results/enter_results.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(sportsDayProvider);
    if (events.isEmpty) return const _EmptyLive();
    final p = ref.watch(progressProvider);
    final houses = ref.watch(standingsProvider);
    final role = ref.watch(roleProvider) ?? Role.spectator;
    final running = events.where((e) => e.status == EventStatus.running).toList();
    final waiting = events.where((e) => e.status == EventStatus.waiting).toList();
    final upcoming = events.where((e) => e.status == EventStatus.upcoming).toList()..sort((a, b) => a.start.compareTo(b.start));

    void open(SportsEvent e) {
      if (e.kind == EventKind.team) {
        toast(context, '${e.name}: house teams, result entered as placings at the station');
        return;
      }
      if (!role.canEnterResults) {
        toast(context, 'Spectators can view results only');
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EnterResultsScreen(eventId: e.id)));
    }

    return ListView(
      key: const Key('live-list'),
      padding: EdgeInsets.zero,
      children: [
        const TabHeader('Live', subtitle: 'Westbrook Academy · Track & Field'),
        Padding(
          padding: pagePad,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: heroGradient, borderRadius: BorderRadius.circular(20), boxShadow: cardShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Event progress', style: TextStyle(fontFamily: kBody, fontSize: 16, color: Colors.white)),
                  const Spacer(),
                  _darkPill('${p.done} of ${p.total} events'),
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${(p.ratio * 100).round()}%', key: const Key('progress-pct'), style: T.number(56, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text('completed on schedule', style: TextStyle(fontFamily: kBody, fontSize: 14, color: Colors.white)),
                  ),
                ]),
                const SizedBox(height: 14),
                ProgressBar(p.ratio, color: Colors.white, track: const Color(0x4DFFFFFF)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _darkPill('${p.running} running now', icon: Icons.circle),
                  _darkPill('${p.waiting} results waiting', icon: Icons.assignment_outlined),
                ]),
              ]),
            ),
            SectionHeader('House standings', action: 'Full board', onAction: () => ref.read(tabProvider.notifier).go(3)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                for (final h in houses)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      key: Key('house-total-${h.house.name}'),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(999), boxShadow: cardShadow),
                      child: Row(children: [
                        HouseTag(h.house, style: T.label.copyWith(fontSize: 15)),
                        const SizedBox(width: 10),
                        Text('${h.points}', style: T.number(18)),
                      ]),
                    ),
                  ),
              ]),
            ),
            SectionHeader('Running now', count: running.length),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                for (var i = 0; i < running.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: C.border),
                  _EventRow(running[i], live: true, onTap: () => open(running[i])),
                ],
              ]),
            ),
            if (waiting.isNotEmpty) ...[
              SectionHeader('Results waiting', count: waiting.length),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  for (var i = 0; i < waiting.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: C.border),
                    _EventRow(
                      waiting[i],
                      trailing: role.canEnterResults
                          ? SizedBox(
                              height: 44,
                              child: FilledButton(
                                key: Key('enter-${waiting[i].id}'),
                                style: FilledButton.styleFrom(backgroundColor: C.accentFill, shape: const StadiumBorder()),
                                onPressed: () => open(waiting[i]),
                                child: const Text('Enter', style: TextStyle(fontFamily: kBody, fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            )
                          : null,
                    ),
                  ],
                ]),
              ),
            ],
            if (upcoming.isNotEmpty) ...[
              const SectionHeader('Up next'),
              AppCard(
                child: Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.timer_outlined, color: C.accentFill),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(upcoming.first.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('${upcoming.first.station} · ${upcoming.first.detail}', style: T.caption),
                    ]),
                  ),
                  Pill(clock(upcoming.first.start), icon: Icons.schedule_rounded, fg: C.ink, bg: C.surfaceAlt),
                ]),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}

Widget _darkPill(String text, {IconData? icon}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0x401F0C18), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: icon == Icons.circle ? 9 : 16, color: Colors.white), const SizedBox(width: 6)],
        Text(text, style: const TextStyle(fontFamily: kBody, fontSize: 14, color: Colors.white)),
      ]),
    );

class _EventRow extends StatelessWidget {
  const _EventRow(this.e, {this.live = false, this.trailing, this.onTap});
  final SportsEvent e;
  final bool live;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (e.kind) {
      EventKind.track => Icons.directions_run_rounded,
      EventKind.field => Icons.straighten_rounded,
      EventKind.team => Icons.groups_outlined,
    };
    return InkWell(
      key: Key('event-${e.id}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(e.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                if (live) const LiveBadge(),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(icon, size: 16, color: C.text2),
                const SizedBox(width: 6),
                Flexible(child: Text('${e.station} · ${e.detail}${e.entries.isEmpty ? '' : ' · ${e.entries.length} entries'}', style: T.caption)),
              ]),
            ]),
          ),
          if (trailing != null) trailing! else const Icon(Icons.chevron_right_rounded, color: C.borderStrong),
        ]),
      ),
    );
  }
}

class _EmptyLive extends ConsumerWidget {
  const _EmptyLive();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(padding: EdgeInsets.zero, children: [
      const TabHeader('Live', subtitle: 'Westbrook Academy', chip: false),
      Padding(
        padding: pagePad,
        child: Column(children: [
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset('assets/images/empty-track.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Pill('First-run setup'),
                  const SizedBox(height: 12),
                  const Text('No events yet', style: TextStyle(fontFamily: kDisplay, fontSize: 28, fontWeight: FontWeight.w800, color: C.ink)),
                  const SizedBox(height: 6),
                  const Text('Create a sports day or tournament and the live overview appears here.', style: TextStyle(fontFamily: kBody, fontSize: 16, color: C.text2, height: 1.4)),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    key: const Key('create-first'),
                    label: 'Create first event',
                    icon: Icons.add_rounded,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateCompetitionScreen())),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    key: const Key('load-sample'),
                    label: 'Import houses and students',
                    icon: Icons.upload_file_outlined,
                    onPressed: () {
                      ref.read(sportsDayProvider.notifier).reset();
                      toast(context, '4 houses and 835 students imported (sample)');
                    },
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('QUICK SETUP GUIDE', style: TextStyle(fontFamily: kBody, fontSize: 13, letterSpacing: 1, color: C.text3)),
              const SizedBox(height: 10),
              for (final s in const ['1. Add houses and teams', '2. Schedule track and field events', '3. Assign teachers to stations'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.radio_button_unchecked_rounded, size: 18, color: C.accentFill),
                    const SizedBox(width: 10),
                    Text(s, style: T.body),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
    ]);
  }
}
