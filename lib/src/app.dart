import 'package:flutter/material.dart';
import './screens/login_screen.dart';

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Secure Notebook',
      home: Scaffold(
        body: LoginScreen(),
      ),
    );
  }
}