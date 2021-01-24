import 'package:flutter/material.dart';
import './handlers/screen_handler.dart';

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Secure Notebook',
      home: Scaffold(
        body: ScreenHandler.getInstance(),
      ),
    );
  }
}