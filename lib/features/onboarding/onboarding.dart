import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});
  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the photos the next screens show, so headers never flash an empty avatar.
    for (final p in const [
      'assets/images/avatar-sam-carter.jpg',
      'assets/images/featured-relay.jpg',
      'assets/images/staff-sam-carter.jpg',
      'assets/images/empty-track.jpg',
      'assets/logo/icon.png',
    ]) {
      precacheImage(AssetImage(p), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(children: [
        Expanded(
          flex: 11,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/hero-sports-day.jpg', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x661F0C18), Color(0x001F0C18), Color(0xD91F0C18)],
                  stops: [0, .35, 1],
                ),
              ),
            ),
            Positioned(
              top: top + 16,
              left: 20,
              right: 20,
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/logo/icon.png', width: 44, height: 44)),
                const SizedBox(width: 10),
                const Text('Heatsheet', style: TextStyle(fontFamily: kDisplay, fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: const Color(0x801F0C18), borderRadius: BorderRadius.circular(999)),
                    child: const Text(SampleData.school, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: kBody, fontSize: 13, color: Colors.white)),
                    ),
                  ),
                ),
              ]),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final h in SampleData.houses)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0x801F0C18), borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(h.name, style: const TextStyle(fontFamily: kBody, fontSize: 13, color: Colors.white)),
                      ]),
                    ),
                ]),
                const SizedBox(height: 16),
                const Text('Run sports day\nfrom one screen.', style: TextStyle(fontFamily: kDisplay, fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 8),
                const Text('Fixtures, results and house points, live for every teacher and every screen.',
                    style: TextStyle(fontFamily: kBody, fontSize: 16, color: Colors.white, height: 1.4)),
              ]),
            ),
          ]),
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('EVERYTHING INSTANT', style: TextStyle(fontFamily: kBody, fontSize: 13, letterSpacing: 1.2, color: C.text2)),
              const SizedBox(height: 10),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                Pill('Auto fixtures', icon: Icons.calendar_month_outlined),
                Pill('Live standings', icon: Icons.emoji_events_outlined),
                Pill('Big-screen mode', icon: Icons.tv_outlined),
              ]),
              const Spacer(),
              PrimaryButton(
                key: const Key('sign-in'),
                label: 'Sign in with school email',
                icon: Icons.mail_outline_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoleScreen())),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  key: const Key('spectator'),
                  style: TextButton.styleFrom(foregroundColor: C.text2, minimumSize: const Size(44, 48)),
                  onPressed: () => ref.read(roleProvider.notifier).set(Role.spectator),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('View live results as a spectator', style: TextStyle(fontFamily: kBody, fontSize: 15)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: C.accentFill),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});
  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  Role picked = Role.organiser;

  static const icons = {
    Role.schoolAdmin: Icons.admin_panel_settings_outlined,
    Role.organiser: Icons.sports_outlined,
    Role.official: Icons.timer_outlined,
    Role.spectator: Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final short = picked == Role.organiser ? 'Organiser' : picked.label;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const StackBar(title: '', subtitle: null),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), children: [
              const Text('How are you helping today?', style: T.display),
              const SizedBox(height: 6),
              const Text('${SampleData.school}, ${SampleData.eventName}', style: T.caption),
              const SizedBox(height: 20),
              for (final r in Role.values) ...[
                AppCard(
                  key: Key('role-${r.name}'),
                  border: r == picked ? C.accentFill : null,
                  onTap: () => setState(() => picked = r),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: r == picked ? C.accent : C.accentTint, borderRadius: BorderRadius.circular(14)),
                      child: Icon(icons[r], color: r == picked ? C.ink : C.accentFill),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.label, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(r.blurb, style: T.caption),
                      ]),
                    ),
                    Icon(r == picked ? Icons.check_circle_rounded : Icons.circle_outlined, color: r == picked ? C.accentFill : C.borderStrong),
                  ]),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              const Row(children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: C.text3),
                SizedBox(width: 6),
                Expanded(child: Text('Your school admin can change your access later', style: TextStyle(fontFamily: kBody, fontSize: 13, color: C.text3))),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PrimaryButton(
              key: const Key('continue-role'),
              label: 'Continue as $short',
              onPressed: () {
                ref.read(roleProvider.notifier).set(picked);
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
