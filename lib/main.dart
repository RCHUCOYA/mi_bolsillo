import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MiBolsilloApp());
}

class MiBolsilloApp extends StatelessWidget {
  const MiBolsilloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiBolsillo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      theme: MiBolsilloTheme.light(),
      darkTheme: MiBolsilloTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
