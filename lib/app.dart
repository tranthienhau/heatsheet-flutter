import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/onboarding/onboarding.dart';
import 'features/shell/shell.dart';
import 'state/providers.dart';

class HeatsheetApp extends ConsumerWidget {
  const HeatsheetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      child: MaterialApp(
        title: 'Heatsheet',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: role == null ? const WelcomeScreen() : const Shell(),
      ),
    );
  }
}
