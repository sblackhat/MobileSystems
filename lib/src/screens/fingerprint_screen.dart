import 'package:MobileSystems/src/options/user_options.dart';
import 'package:MobileSystems/src/screens/notebook_screen.dart';
import 'package:MobileSystems/src/services/auth_services.dart';
import 'package:MobileSystems/src/validator/user_input_validator.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_safetynet_attestation/flutter_safetynet_attestation.dart';
import 'package:MobileSystems/src/screens/login_screen.dart';

class FingerScreen extends StatefulWidget {
  @override
  _FingerScreenState createState() => _FingerScreenState();
}

class _FingerScreenState extends State<FingerScreen> {
  String _authorized = "Not authorized";
  bool _jailbroken;
  bool _developerMode;
  //Manage OTP buttom
  static const _timerDuration = 30;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;
  bool _init = true;

  GooglePlayServicesAvailability _gmsStatus;

  bool _smsVerif = false;

  UserOptions options;

  Future<CanAuthenticateResponse> _checkAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    return response;
  }

  _showDialog(String dialogTitle, String dialogMessage) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: SingleChildScrollView(
              child: Text('$dialogMessage'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _authenticate() async {
    if (_jailbroken) {
      _showDialog("You cannot use this app!",
          "Your device is rooted or has an unlocked bootloader.");
      return;
    }
      if(options.smsOTP){
        String phone = await Validator.getPhone();
        AuthResult auth = await AuthProvider.authPhone(phone, context);
        if(!auth.result){
          _showDialog("SMS verification failed", auth.message);
          _timerStream.sink.add(30);
          _activeCounter();
        }
      }

      bool res = await Validator.logInFinger();
      print(res);
      if(res){
        Navigator.pop(context);
        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteBookScreen()));
      }
    }

  _activeCounter() {
    _resendCodeTimer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0 && !_init)
        _timerStream.sink.add(_timerDuration - timer.tick);
      else {
        _timerStream.sink.add(0);
        _resendCodeTimer.cancel();
      }
    });
  }


  _checkJailBreak() async {
    bool jailbroken;
    bool developerMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
    } on PlatformException {
      jailbroken = true;
      developerMode = true;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _jailbroken = jailbroken;
      _developerMode = developerMode;
    });
  }

  Future<void> initPlatformState() async {
    GooglePlayServicesAvailability gmsAvailability;
    try {
      gmsAvailability =
          await FlutterSafetynetAttestation.googlePlayServicesAvailability();
    } on PlatformException {
      gmsAvailability = null;
      _showDialog("OTP not supported",
          "Your device is not compatible with OTP verification.");
    }

    if (!mounted) return;

    setState(() {
      _gmsStatus = gmsAvailability;
    });
  }

  @override
  initState() {
    super.initState();
    options = new UserOptions();
    _checkJailBreak();
    _checkAuthenticate();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: UserOptions.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            options = snapshot.data;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0x37474F),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Log In Text
            Center(
                child: Text(
              "Login",
              style: TextStyle(
                  color: Colors.white10,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            )),

            Center(
                child: Text(
              "Secure Notebook",
              style: TextStyle(
                  color: Colors.white10,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            )),

            Container(
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    color: Colors.blue,
                    size: 120,
                  ),
                  Text(
                    "FingerPrint Auth",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamBuilder(
                      stream: _timerStream.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: (snapshot.data == 0 || _init || !options.smsOTP)
                                ? () {
                                    _init = false;
                                    _authenticate();
                                  }
                                : null,
                            elevation: 0.0,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 24.0),
                              child: (snapshot.data == 0 || !options.smsOTP) ? Text("Authenticate",style: TextStyle(color: Colors.white)) : Text(
                                ' Wait to log in again ${snapshot.hasData ? snapshot.data.toString() : 30} seconds ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }),
                  Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: (options.logInByPassword) ? (){
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                            } : null,
                            elevation: 0.0,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 24.0),
                              child: Text("Log in using password",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }else{
    return CircularProgressIndicator();
  }
});
}
