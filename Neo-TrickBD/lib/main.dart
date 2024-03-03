import 'package:flutter/material.dart';

import 'api/dio.dart';
import 'home.dart';

int get widthBreakpoint => 500;

double getScreenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;

double getScreenHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

bool isDarkTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDioClient();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeoTrickBD',
      home: const Home(),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff0072bc),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xff0072bc),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    ),
  );
}
