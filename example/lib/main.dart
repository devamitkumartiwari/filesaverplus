import 'package:material_ui/material_ui.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const FileSaverPlusExampleApp());
}

/// Teal: the main color, shared with the launcher icon background.
const Color kSeedColor = Color(0xFF00897B);

/// Amber: the accent color, shared with the launcher icon arrow.
const Color kAccentColor = Color(0xFFFFB300);

class FileSaverPlusExampleApp extends StatelessWidget {
  const FileSaverPlusExampleApp({super.key});

  ThemeData _theme(Brightness brightness) {
    // Teal drives every role; the tertiary (accent) roles come from an amber
    // scheme so they keep proper contrast in both light and dark mode.
    final amber = ColorScheme.fromSeed(
      seedColor: kAccentColor,
      brightness: brightness,
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: brightness,
      tertiary: amber.primary,
      onTertiary: amber.onPrimary,
      tertiaryContainer: amber.primaryContainer,
      onTertiaryContainer: amber.onPrimaryContainer,
    );
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileSaverPlus',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const HomePage(),
    );
  }
}
