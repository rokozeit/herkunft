import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'search_page.dart';
import 'dart:io' as io;

void main() async {
  if (io.Platform.isWindows || io.Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(400, 600));
    WindowManager.instance.setTitle("food origin");
    WindowManager.instance.setSize(const Size(400, 600));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'food origin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}
