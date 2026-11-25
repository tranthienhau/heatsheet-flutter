import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../domain/models.dart';
import 'theme.dart';

House houseInfo(HouseId id) => SampleData.houses.firstWhere((h) => h.id == id);

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.border, this.color = C.surface});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? border;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: r,
        boxShadow: cardShadow,
        border: border == null ? null : Border.all(color: border!, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        child: InkWell(borderRadius: r, onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 56});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? C.accentPressed : C.accentFill),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          elevation: const WidgetStatePropertyAll(0),
        ),
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontFamily: kBody, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 56, this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final b = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.ink,
        backgroundColor: C.surface,
        side: const BorderSide(color: C.borderStrong, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      onPressed: onPressed,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label, style: const TextStyle(fontFamily: kBody, fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    );
    return SizedBox(height: height, width: expand ? double.infinity : null, child: b);
  }
}

/// Small pill used for chips, tags and status labels.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.fg = C.accentFill, this.bg = C.accentTint, this.icon, this.dot});
  final String text;
  final Color fg, bg;
  final IconData? icon;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot != null) ...[Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)), const SizedBox(width: 6)],
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Text(text, style: TextStyle(fontFamily: kBody, fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});
  @override
  Widget build(BuildContext context) => const Pill('LIVE', dot: C.accentFill);
}

/// House colour dot + name, always together (colour is never the only signal).
class HouseTag extends StatelessWidget {
  const HouseTag(this.house, {super.key, this.style = T.caption, this.trailing});
  final HouseId house;
  final TextStyle style;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final h = houseInfo(house);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(trailing == null ? h.name : '${h.name} $trailing', style: style),
    ]);
  }
}

class SelectChip extends StatelessWidget {
  const SelectChip(this.label, {super.key, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? C.accentFill : C.accentTint,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            widthFactor: 1,
            child: Text(label, style: TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : C.accentFill)),
          ),
        ),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.items, required this.index, required this.onChanged, this.keyPrefix = 'seg'});
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: C.surfaceAlt, borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: GestureDetector(
              key: Key('$keyPrefix-$i'),
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == index ? C.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: i == index ? cardShadow : null,
                ),
                child: Text(items[i], style: TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w600, color: i == index ? C.ink : C.text2)),
              ),
            ),
          ),
      ]),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.count, this.action, this.onAction, this.actionKey});
  final String title;
  final int? count;
  final String? action;
  final VoidCallback? onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(children: [
        Text(title, style: const TextStyle(fontFamily: kDisplay, fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: const BoxDecoration(color: C.accentFill, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(999))),
            child: Text('$count', style: const TextStyle(fontFamily: kBody, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
        const Spacer(),
        if (action != null)
          TextButton(
            key: actionKey,
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: C.accentFill, minimumSize: const Size(44, 44)),
            child: Text(action!, style: const TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.photo, {super.key, this.size = 44, this.initials = ''});
  final String? photo;
  final double size;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: C.support,
        border: Border.all(color: C.surface, width: 2),
        image: photo == null ? null : DecorationImage(image: AssetImage(photo!), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: photo == null ? Text(initials, style: const TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)) : null,
    );
  }
}

/// Header on tab screens: big title, event chip, organiser avatar.
class TabHeader extends StatelessWidget {
  const TabHeader(this.title, {super.key, this.subtitle = '${SampleData.school} · Fri 28 Nov', this.chip = true});
  final String title;
  final String subtitle;
  final bool chip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 6, children: [
              Text(title, style: T.display),
              if (chip) const Pill(SampleData.eventName),
            ]),
            const SizedBox(height: 4),
            Text(subtitle, style: T.caption),
          ]),
        ),
        const Avatar('assets/images/avatar-sam-carter.jpg', size: 48),
      ]),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton(this.icon, {super.key, required this.onTap, this.filled = false, this.size = 48, this.tooltip});
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? C.accentFill : C.surface,
      shape: CircleBorder(side: filled ? BorderSide.none : const BorderSide(color: C.borderStrong, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: filled ? Colors.white : C.ink, size: 22, semanticLabel: tooltip),
        ),
      ),
    );
  }
}

/// Top bar for stack screens (no tab bar).
class StackBar extends StatelessWidget {
  const StackBar({super.key, required this.title, this.subtitle, this.close = false, this.trailing, this.backKey = 'back'});
  final String title;
  final String? subtitle;
  final bool close;
  final Widget? trailing;
  final String backKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        RoundIconButton(close ? Icons.close_rounded : Icons.arrow_back_rounded, key: Key(backKey), size: 44, tooltip: close ? 'Close' : 'Back', onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontFamily: kDisplay, fontSize: 24, fontWeight: FontWeight.w800, color: C.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (subtitle != null) Text(subtitle!, style: T.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        ?trailing,
      ]),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.color = C.accentFill, this.track = C.surfaceAlt, this.height = 8});
  final double value;
  final Color color, track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(children: [
        Container(height: height, color: track),
        FractionallySizedBox(widthFactor: value.clamp(0, 1), child: Container(height: height, color: color)),
      ]),
    );
  }
}

String statusLabel(EventStatus s) => switch (s) {
      EventStatus.upcoming => 'Upcoming',
      EventStatus.running => 'Running',
      EventStatus.waiting => 'Results waiting',
      EventStatus.done => 'Completed',
    };

Widget statusPill(String status) => switch (status) {
      'Live' || 'In progress' => Pill(status, dot: C.accentFill),
      'Completed' => const Pill('Completed', fg: C.success, bg: C.successTint),
      'Draft' => const Pill('Draft', fg: C.text2, bg: C.surfaceAlt),
      _ => Pill(status, fg: C.text2, bg: C.surfaceAlt),
    };

void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 2200)));
}

const pagePad = EdgeInsets.fromLTRB(20, 8, 20, 32);
