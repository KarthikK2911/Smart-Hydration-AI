import 'package:flutter/material.dart';
import 'screens/hydration_prompt.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HydrationApp());
}

class HydrationApp extends StatelessWidget {
  const HydrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hydration AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: HydrationPrompt(),
    );
  }
}