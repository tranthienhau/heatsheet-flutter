import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider) ?? Role.spectator;
    Widget row(String key, IconData icon, String title, String sub, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            key: Key(key),
            onTap: onTap,
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: C.accentFill)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(sub, style: T.caption),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: C.borderStrong),
            ]),
          ),
        );
    return ListView(key: const Key('more-list'), padding: EdgeInsets.zero, children: [
      const TabHeader('More', chip: false),
      Padding(
        padding: pagePad,
        child: Column(children: [
          const SizedBox(height: 8),
          AppCard(
            child: Row(children: [
              const Avatar('assets/images/staff-sam-carter.jpg', size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Mr Sam Carter', style: T.title),
                  Text('${role.label} · ${SampleData.school}', style: T.caption),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          row('open-houses', Icons.shield_outlined, 'Houses and teams', '4 houses · year groups · rosters',
              () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HousesScreen()))),
          if (role == Role.schoolAdmin || role == Role.organiser)
            row('open-roles', Icons.admin_panel_settings_outlined, 'Staff and roles', 'Who can create, edit and enter results',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RolesScreen()))),
          row('switch-role', Icons.swap_horiz_rounded, 'Switch role', 'See the app as an official or a spectator', () {
            ref.read(tabProvider.notifier).go(0);
            ref.read(roleProvider.notifier).set(null);
          }),
          row('first-run', Icons.restart_alt_rounded, 'Preview a new school', 'The first-run screen before any event exists', () {
            ref.read(sportsDayProvider.notifier).clear();
            ref.read(tabProvider.notifier).go(0);
          }),
        ]),
      ),
    ]);
  }
}

class HousesScreen extends StatefulWidget {
  const HousesScreen({super.key});
  @override
  State<HousesScreen> createState() => _HousesScreenState();
}

class _HousesScreenState extends State<HousesScreen> {
  int seg = 0;
  HouseId house = HouseId.falcons;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final roster = SampleData.athletes.where((a) => a.house == house && a.name.toLowerCase().contains(query.toLowerCase())).toList()
      ..sort((a, b) => a.year.compareTo(b.year));
    final years = <int, int>{};
    for (final a in SampleData.athletes) {
      years[a.year] = (years[a.year] ?? 0) + 1;
    }
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const StackBar(title: 'Houses and teams', subtitle: SampleData.school),
          Expanded(
            child: ListView(key: const Key('houses-list'), padding: pagePad, children: [
              Segmented(items: const ['Houses', 'Year groups', 'Teams'], index: seg, keyPrefix: 'house-seg', onChanged: (i) => setState(() => seg = i)),
              const SizedBox(height: 16),
              if (seg == 0) ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    for (final h in SampleData.houses)
                      GestureDetector(
                        key: Key('house-${h.id.name}'),
                        onTap: () => setState(() => house = h.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: cardShadow,
                            border: h.id == house ? Border.all(color: C.accentFill, width: 2) : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(height: 10, color: h.color),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(h.name, style: const TextStyle(fontFamily: kDisplay, fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)),
                                Text('${h.students} students', style: T.caption),
                                const SizedBox(height: 4),
                                Text('Captain ${h.captain}', style: const TextStyle(fontFamily: kBody, fontSize: 12, color: C.text2)),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                  ],
                ),
                SectionHeader('${houseInfo(house).name} roster', count: roster.length),
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  style: T.body,
                  decoration: InputDecoration(
                    hintText: 'Search ${houseInfo(house).name} students',
                    hintStyle: const TextStyle(fontFamily: kBody, color: C.text3),
                    prefixIcon: const Icon(Icons.search_rounded, color: C.text2),
                    filled: true,
                    fillColor: C.surface,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                for (final a in roster) ...[
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(children: [
                      Avatar(a.photo, size: 44, initials: a.name.split(' ').map((w) => w[0]).join()),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600))),
                      Pill(a.form),
                      const SizedBox(width: 6),
                      Pill('Year ${a.year}', fg: C.text2, bg: C.surfaceAlt),
                    ]),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (seg == 1)
                for (final y in (years.keys.toList()..sort())) ...[
                  AppCard(
                    child: Row(children: [
                      Text('Year $y', style: T.title),
                      const Spacer(),
                      for (final h in SampleData.houses)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(width: 10, height: 10, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
                        ),
                      const SizedBox(width: 10),
                      Text('${years[y]} in this demo', style: T.caption),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
              if (seg == 2)
                for (final t in SampleData.basketTeams) ...[
                  AppCard(
                    child: Row(children: [
                      HouseTag(t.house!, style: T.label, trailing: t.name.split(' ').last),
                      const Spacer(),
                      const Text('Year 9 basketball', style: T.caption),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton(
              label: 'Assign students',
              icon: Icons.person_add_alt_outlined,
              onPressed: () => toast(context, 'Drag students between houses, or import a class list (CSV)'),
            ),
          ),
        ]),
      ),
    );
  }
}

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(staffProvider);
    final lead = staff.first;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const StackBar(title: 'Staff and roles', subtitle: 'Access only to the events each person needs'),
          Expanded(
            child: ListView(key: const Key('roles-list'), padding: pagePad, children: [
              AppCard(
                border: C.accentTint,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Avatar(lead.photo, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lead.name, style: T.title),
                        Text('${lead.title} · ${lead.scope}', style: T.caption),
                      ]),
                    ),
                    Pill(lead.role == Role.organiser ? 'Organiser' : lead.role.label),
                  ]),
                  const Divider(height: 24, color: C.border),
                  const Text('EVENT PERMISSIONS', style: TextStyle(fontFamily: kBody, fontSize: 13, letterSpacing: 1, color: C.text3)),
                  for (final k in lead.access.keys)
                    SizedBox(
                      height: 52,
                      child: Row(children: [
                        Expanded(child: Text(k, style: T.body)),
                        Switch(key: Key('perm-$k'), value: lead.access[k]!, onChanged: (_) => ref.read(staffProvider.notifier).toggle(lead.name, k)),
                      ]),
                    ),
                ]),
              ),
              SectionHeader('Other staff and helpers', count: staff.length - 1),
              for (final s in staff.skip(1)) ...[
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Avatar(s.photo, size: 48, initials: 'Y11'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.name, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('${s.title} · ${s.scope}', style: T.caption),
                      ]),
                    ),
                    s.role == Role.schoolAdmin ? Pill(s.role.label) : Pill(s.role.label, fg: C.text2, bg: C.surfaceAlt),
                  ]),
                ),
                const SizedBox(height: 10),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton(label: 'Invite staff', icon: Icons.person_add_alt_1_outlined, onPressed: () => toast(context, 'Invite link copied, valid for 24 hours')),
          ),
        ]),
      ),
    );
  }
}
