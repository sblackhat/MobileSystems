import 'dart:async';
import 'package:MobileSystems/src/screens/sign_up.dart';
import 'package:MobileSystems/src/validator/validator_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystems/src/bloc/bloc_log_in.dart';
import 'package:MobileSystems/src/screens/notebook_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safetynet_attestation/flutter_safetynet_attestation.dart';
import '../options/user_options.dart';
import 'fingerprint_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc _bloc = LoginBloc();
  TextEditingController _passController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  //Manage the OTP button
   GooglePlayServicesAvailability _gmsStatus;
  static const _timerDuration = 30;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;
  UserOptions options;
  

  bool _init = true;

  @override
  void initState() {
    _activeCounter();
    options = new UserOptions();
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    GooglePlayServicesAvailability gmsAvailability;
    try {
      gmsAvailability =
          await FlutterSafetynetAttestation.googlePlayServicesAvailability();
    } on PlatformException {
      gmsAvailability = null;
    }

    if (!mounted) return;

    setState(() {
      _gmsStatus = gmsAvailability;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Black Notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            //email field
            StreamBuilder<String>(
                stream: _bloc.userNameStream,
                builder: (context, snapshot) {
                  return userNameField(context, snapshot);
                }),

            //Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordStream,
              builder: (context, snapshot) {
                return passwordField(context, snapshot);
              },
            ),

            //FORGET PASSWORD FIELD

            //SUBMIT BUTTON
            StreamBuilder<bool>(
                stream: _bloc.submitValid,
                builder: (context, snapshot) {
                  return _submitButton(context, snapshot);
                }),

            //Add some padding
            Padding(padding: EdgeInsets.only(top: 30.0)),

            //SIGN UP
            _registerButton(),

            Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: (options.logInByFinger) ? (){
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                              builder: (context) => FingerScreen()));
                            } : null,
                            elevation: 0.0,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 24.0),
                              child: Text("Log in using fingerprint",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
          ],
        ),
      ),
    );
  }

  Widget userNameField(BuildContext context, dynamic snapshot) {
    return TextField(
      maxLength: 40,
      controller: _userController,
      decoration: InputDecoration(
        labelText: 'User',
        errorText: snapshot.error,
      ),
      onChanged: (String value) {
        _bloc.userNameOnChange(value);
      },
    );
  }

  Widget passwordField(BuildContext context, dynamic snapshot) {
    return TextField(
      enableSuggestions: false,
      autocorrect: false,
      obscureText: true,
      controller: _passController,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: snapshot.error,
      ),
      onChanged: (String value) {
        _bloc.passwordOnChange(value);
      },
    );
  }

  Widget _submitButton(ctx, snap) {
    return StreamBuilder(
      stream: _timerStream.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return SizedBox(
            width: 300,
            height: 30,
            child: RaisedButton(
              textColor: Theme.of(context).accentColor,
              child: Center(
                  child: snapshot.data == 0
                      ? Text('Submit',)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                ' Resend OTP in ${snapshot.hasData ? snapshot.data.toString() : 30} seconds '),
                          ],
                        )),
              onPressed: (snapshot.data == 0 && (snap.hasData && snap.data))
                  ? () {
                      _init = false;
                      _onPressSubmit(context);
                    }
                  : null,
            ));
      },
    );
  }

  Future<void> _showDialog(String dialogTitle,String dialogMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: SingleChildScrollView(
            child: Text(dialogMessage),
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
      },
    );
  }

  Future<bool> _requestSafetyNetAttestation() async {
    String dialogTitle, dialogMessage;
    try {
      String rand = _bloc.getRandom();
      JWSPayload res =
          await FlutterSafetynetAttestation.safetyNetAttestationPayload(
              rand);
      if(!res.ctsProfileMatch){
        dialogMessage = solveResponse(res);
        _showDialog("ERROR! Your device cannot use this app", dialogMessage);
      }
      return true;
    } catch (e) {
      dialogTitle = 'ERROR!';
      if (e is PlatformException) {
        dialogMessage = e.message;
      } else {
        dialogMessage = e?.toString();
      }
      _showDialog(dialogTitle, dialogMessage);
    return false;
    }
  }

   String solveResponse(JWSPayload response){
    if(response.basicIntegrity)
      return "Your device has an unlocked bootloader or custom ROM";
    else return "Emulated device or rooted device";
  }

  Future<void> _onPressSubmit(context) async {
    bool _registered = await _bloc.isRegistered();
    if (_registered) {
        bool res = await _requestSafetyNetAttestation();
        if(res) _logInUser(context); 
    } else
      _showDialog("Log In Failed","Not registered yet? Sign up");
  }

  _goToNoteScreen(context) {
    _clearLoginScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => NoteBookScreen()));
  }
  _goToSignUpScreen(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  _clearLoginScreen() {
    _userController.clear();
    _passController.clear();
  }

  Widget _registerButton() {
    return Stack(children: <Widget>[
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Not registered yet? Sign up"),
            RaisedButton(
              child: Text("SIGN UP"),
              onPressed: () {
                _goToSignUpScreen(context);
              },
            ),
          ],
        ),
      )
    ]);
  }

  _codeSent(String verificationId, [int forceResendingToken]) {
    //show dialog to take input from the user
    final TextEditingController _codeController = new TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Enter SMS Code"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Done"),
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  onPressed: () async {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    String smsCode =
                        _codeController.text.trim(); // Update the UI
                    PhoneAuthCredential
                        phoneAuthCredential = // Create a PhoneAuthCredential with the code
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsCode);
                    try {
                      await auth.signInWithCredential(phoneAuthCredential);
                      if (auth.currentUser != null) {
                        // Sign the user in with the credential
                        var result = await _bloc.submitLogin();

                        if (result) {
                
                          Navigator.of(context).pop();
                          _goToNoteScreen(context);
                        } else {
                          //Show the wrongPassword dialog
                          Navigator.of(context).pop();
                          _showDialog("Wrong username/password","You have introduced the wrong password/username.");
                          _timerStream.sink.add(30);
                          _activeCounter();
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      String message = solveMessage(e);
                      Navigator.of(context).pop();
                      _timerStream.sink.add(30);
                      _activeCounter();
                      _showDialog("Log In Failed",message);
                    }
                  },
                )
              ],
            ));
  }

  Future _logInUser(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final phone = await _bloc.getPhone();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 30),
        verificationCompleted: (AuthCredential authCredential) async {
          await _auth.signInWithCredential(authCredential);
          // Sign the user in with the credential
          var result = await _bloc.submitLogin();

          if (result) {
            Navigator.of(context).pop();
            _goToNoteScreen(context);
          } else {
            //Show the wrongPassword dialog
            _showDialog("Wrong username/password", "You have introduced the wrong password/username.");
          }
        },
        verificationFailed: (FirebaseAuthException authException) {
          _showDialog("Log In Failed",authException.message);
        },
        codeSent: (String verID, int forceResendingToken) async {
          _codeSent(verID, forceResendingToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
