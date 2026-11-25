import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

const _cardW = 168.0, _cardH = 92.0, _slot = 108.0, _gap = 40.0;

/// Knockout bracket: quarter-finals to the final, plus the third-place match.
/// Tap a tie whose teams are known to enter its score; winners move on automatically.
class BracketScreen extends ConsumerStatefulWidget {
  const BracketScreen({super.key});
  @override
  ConsumerState<BracketScreen> createState() => _BracketScreenState();
}

class _BracketScreenState extends ConsumerState<BracketScreen> {
  final scroll = ScrollController();
  int round = 1;

  static const names = ['Quarter-finals', 'Semi-finals', 'Final'];

  @override
  Widget build(BuildContext context) {
    final rounds = ref.watch(cupProvider);
    final role = ref.watch(roleProvider) ?? Role.spectator;
    final semis = rounds[1];
    final third = Tie(semis[0].loser, semis[1].loser, slot: 'Sat 15:00', venue: 'Pitch 2');
    final height = rounds.first.length * _slot;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const StackBar(title: 'Inter-school Football Cup', subtitle: '8 schools · Knockout · Westbrook Sports Ground'),
          SizedBox(
            height: 56,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SelectChip(names[i], key: Key('round-$i'), selected: round == i, onTap: () {
                    setState(() => round = i);
                    scroll.animateTo((i * (_cardW + _gap) - 20).clamp(0, scroll.position.maxScrollExtent), duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                  }),
                ),
            ]),
          ),
          Expanded(
            child: ListView(key: const Key('bracket-list'), padding: const EdgeInsets.only(bottom: 24), children: [
              SingleChildScrollView(
                controller: scroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SizedBox(
                  width: 3 * _cardW + 2 * _gap,
                  height: height,
                  child: Stack(children: [
                    Positioned.fill(child: CustomPaint(painter: _Lines(rounds.length, rounds.first.length))),
                    for (var r = 0; r < rounds.length; r++)
                      for (var i = 0; i < rounds[r].length; i++)
                        Positioned(
                          left: r * (_cardW + _gap),
                          top: _centre(r, i) - _cardH / 2,
                          child: _TieCard(
                            rounds[r][i],
                            key: Key('tie-$r-$i'),
                            isFinal: r == rounds.length - 1,
                            onTap: role.canEnterResults && rounds[r][i].a != null && rounds[r][i].b != null && !rounds[r][i].played
                                ? () => _score(context, r, i, rounds[r][i])
                                : null,
                          ),
                        ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.military_tech_outlined, color: C.accentFill),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Third-place match', style: T.label),
                        const SizedBox(height: 2),
                        Text('${third.slot} · ${third.venue}', style: T.caption),
                        Text('${third.a ?? 'Loser SF1'} vs ${third.b ?? 'Loser SF2'}', style: T.caption),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _score(BuildContext context, int r, int i, Tie t) {
    var a = 0, b = 0;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          Widget side(String name, int v, ValueChanged<int> on, String k) => Expanded(
                child: Column(children: [
                  Text(name, style: T.label.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('$v', style: T.number(48)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    RoundIconButton(Icons.remove_rounded, tooltip: 'Minus', onTap: v > 0 ? () => on(v - 1) : null),
                    const SizedBox(width: 10),
                    RoundIconButton(Icons.add_rounded, key: Key('$k-plus'), tooltip: 'Plus', filled: true, onTap: () => on(v + 1)),
                  ]),
                ]),
              );
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(names[r], style: T.title),
              const SizedBox(height: 16),
              Row(children: [side(t.a!, a, (v) => set(() => a = v), 'tie-a'), side(t.b!, b, (v) => set(() => b = v), 'tie-b')]),
              const SizedBox(height: 20),
              PrimaryButton(
                key: const Key('save-tie'),
                label: a == b ? 'Level: decide on penalties (4-3)' : 'Save result',
                onPressed: () {
                  ref.read(cupProvider.notifier).score(r, i, a, b, pensA: a == b ? 4 : null, pensB: a == b ? 3 : null);
                  Navigator.of(ctx).pop();
                },
              ),
            ]),
          );
        },
      ),
    );
  }
}

double _centre(int round, int i) {
  final span = 1 << round;
  return (span * i + (span - 1) / 2) * _slot + _slot / 2;
}

class _Lines extends CustomPainter {
  _Lines(this.rounds, this.first);
  final int rounds, first;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.borderStrong
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var count = first;
    for (var r = 0; r < rounds - 1; r++) {
      final x0 = r * (_cardW + _gap) + _cardW;
      final xm = x0 + _gap / 2;
      final x1 = x0 + _gap;
      for (var i = 0; i < count; i += 2) {
        final y1 = _centre(r, i), y2 = _centre(r, i + 1), yn = _centre(r + 1, i ~/ 2);
        canvas.drawPath(
            Path()
              ..moveTo(x0, y1)
              ..lineTo(xm, y1)
              ..lineTo(xm, y2)
              ..lineTo(x0, y2)
              ..moveTo(xm, yn)
              ..lineTo(x1, yn),
            p);
      }
      count ~/= 2;
    }
  }

  @override
  bool shouldRepaint(_Lines old) => false;
}

class _TieCard extends StatelessWidget {
  const _TieCard(this.t, {super.key, this.isFinal = false, this.onTap});
  final Tie t;
  final bool isFinal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget line(String? name, int? score, int? pens) {
      final win = t.winner != null && t.winner == name;
      return Row(children: [
        Expanded(
          child: Text(name ?? 'TBD',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: win ? FontWeight.w800 : FontWeight.w500, color: name == null ? C.text3 : C.ink)),
        ),
        if (score != null) Text(pens == null ? '$score' : '$score ($pens)', style: T.number(15, color: win ? C.accentFill : C.text2)),
      ]);
    }

    return SizedBox(
      width: _cardW,
      height: _cardH,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        border: isFinal ? C.accentFill : (onTap != null ? C.accentTint : null),
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          line(t.a, t.scoreA, t.pensA),
          const SizedBox(height: 6),
          line(t.b, t.scoreB, t.pensB),
          const Spacer(),
          Row(children: [
            if (isFinal) ...[const Icon(Icons.emoji_events_outlined, size: 14, color: C.accentFill), const SizedBox(width: 4)],
            Expanded(child: Text(t.played ? 'FT · ${t.venue}' : '${t.slot} · ${t.venue}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.text2))),
          ]),
        ]),
      ),
    );
  }
}
