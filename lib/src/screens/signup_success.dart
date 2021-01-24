import 'package:MobileSystems/src/handlers/screen_handler.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final String method;

  RegisterScreen({this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Successfuly registered in the notebook!",
              style: TextStyle(color: Colors.lightBlue, fontSize: 32),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Using $method method",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            RaisedButton(
                child: Text("Sign In"),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  var screen = ScreenHandler.getInstance();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                }),
          ],
        ),
      ),
    );
  }
}
