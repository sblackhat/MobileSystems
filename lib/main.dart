import 'package:MobileSystems/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystems/src/options/user_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  UserOptions.init();
  runApp(MyApp());
}


