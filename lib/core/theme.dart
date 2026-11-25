import 'package:flutter/material.dart';

/// Tokens from the Stitch design (DESIGN.md, palette P91 after the contrast check).
class C {
  static const bg = Color(0xFFFCF4F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7EAF2);
  static const accent = Color(0xFFFC69C3); // large fills, icons, never white text
  static const accentFill = Color(0xFFCA047E); // white labels go here only
  static const accentTint = Color(0xFFFEE6F5);
  static const accentPressed = Color(0xFFC30379);
  static const support = Color(0xFFB09EFA);
  static const supportStrong = Color(0xFF9880FA);
  static const ink = Color(0xFF1F0C18);
  static const text2 = Color(0xFF5E4656);
  static const text3 = Color(0xFF7A6271);
  static const border = Color(0xFFF0DDE8);
  static const borderStrong = Color(0xFFB682AE);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);
  static const deep = Color(0xFF6A2BB8); // display-mode gradient end
  static const gold = Color(0xFFE0A100);
  static const silver = Color(0xFF9A9AA8);
  static const bronze = Color(0xFFB8733A);
}

const kDisplay = 'Sniglet';
const kBody = 'VarelaRound';

class T {
  static const display = TextStyle(fontFamily: kDisplay, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: C.ink, height: 1.15);
  static const title = TextStyle(fontFamily: kBody, fontSize: 20, fontWeight: FontWeight.w600, color: C.ink, height: 1.3);
  static const body = TextStyle(fontFamily: kBody, fontSize: 16, color: C.ink, height: 1.4);
  static const label = TextStyle(fontFamily: kBody, fontSize: 14, fontWeight: FontWeight.w500, color: C.ink);
  static const caption = TextStyle(fontFamily: kBody, fontSize: 13, fontWeight: FontWeight.w500, color: C.text2);
  static TextStyle number(double size, {Color color = C.ink}) =>
      TextStyle(fontFamily: kDisplay, fontSize: size, fontWeight: FontWeight.w800, color: color, height: 1, fontFeatures: const [FontFeature.tabularFigures()]);
}

const cardShadow = [
  BoxShadow(color: Color(0x0A1F0C18), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F1F0C18), blurRadius: 24, offset: Offset(0, 8)),
];

const heroGradient = LinearGradient(colors: [C.accentFill, C.accentPressed], begin: Alignment.topLeft, end: Alignment.bottomRight);
const displayGradient = LinearGradient(colors: [C.accentFill, C.deep], begin: Alignment.topLeft, end: Alignment.bottomRight);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: kBody,
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: C.accentFill, primary: C.accentFill, surface: C.surface, brightness: Brightness.light),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink, fontFamily: kBody),
    splashFactory: InkRipple.splashFactory,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.ink,
      contentTextStyle: TextStyle(fontFamily: kBody, fontSize: 14, color: Colors.white),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accentFill : C.borderStrong),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}
