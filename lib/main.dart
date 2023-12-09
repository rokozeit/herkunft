import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'search_page.dart';
import 'dart:io' as io;

void main() async {
  if (io.Platform.isWindows || io.Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    _configureWindowManager();
  }

  runApp(const MyApp());
}

void _configureWindowManager() {
  WindowManager.instance.setMinimumSize(const Size(400, 600));
  WindowManager.instance.setTitle("Food Origin");
  WindowManager.instance.setSize(const Size(400, 600));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Origin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lime,
          // ···
          // brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}
