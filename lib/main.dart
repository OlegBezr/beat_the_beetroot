import 'package:beat_the_beetroot/firebase/firebase_options.dart';
import 'package:beat_the_beetroot/pages/fields_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beat the Beetroot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FieldsPage(),
    );
  }
}
