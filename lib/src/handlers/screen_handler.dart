import 'package:MobileSystems/src/options/user_options.dart';
import 'package:MobileSystems/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../screens/fingerprint_screen.dart';


class ScreenHandler extends StatelessWidget {
  @override
  Widget build(context) {
    return FutureBuilder<UserOptions>(
      future: UserOptions.getInstance(),
      builder: (context, AsyncSnapshot<UserOptions> snapshot) {
        if (snapshot.hasData) {
          print("heeee");
          print(snapshot.data.logInByFinger);
          return (snapshot.data.logInByFinger) ? new FingerScreen() : new LoginScreen();
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }

  static getInstance(){
    UserOptions options = new UserOptions();
    if(options.logInByFinger) return new FingerScreen();
    else return new LoginScreen();
  }
}