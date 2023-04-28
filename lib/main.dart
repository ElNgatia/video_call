import 'package:flutter/material.dart';
import 'package:video_call/index.dart';


void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const IndexPage(),
    );
  }
}

