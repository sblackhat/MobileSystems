import 'dart:async';
import 'package:MobileSystems/src/bloc/bloc_sign_up.dart';
import 'package:MobileSystems/src/options/user_options.dart';
import 'package:MobileSystems/src/screens/signup_success.dart';
import 'package:MobileSystems/src/services/auth_services.dart';
import 'package:MobileSystems/src/services/captcha.dart';
import 'package:MobileSystems/src/validator/validator_helpers.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safetynet_attestation/flutter_safetynet_attestation.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  SignUpBloc _bloc = SignUpBloc();
  //Controllers for the UI
  TextEditingController _passController = TextEditingController();
  TextEditingController _passRepeatController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  UserOptions options = new UserOptions();
  //Manage the OTP button
  static const _timerDuration = 30;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;
  bool _init = true;

  GooglePlayServicesAvailability _gmsStatus;

  bool _smsOtp = false;
  bool _finger = false;
  bool _password = false;

  bool _validPhone = false;

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

  Future<bool> _requestSafetyNetAttestation() async {
    String dialogTitle, dialogMessage;
    try {
      String rand = new String.fromCharCodes(generateRandomKey());
      JWSPayload res =
          await FlutterSafetynetAttestation.safetyNetAttestationPayload(rand);
      if (!res.ctsProfileMatch) {
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

  Future<CanAuthenticateResponse> _checkAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    return response;
  }

  Future<void> _initPlatformState() async {
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

  @override
  void initState() {
    if (options.smsOTP) {
      _activeCounter();
      //_initPlatformState();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register in the notebook')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            //Phone Number field
            Text("Phone Number", style: TextStyle(fontSize: 12)),

            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber phone) {
                _bloc.phoneNumberOnChange = phone.phoneNumber;
              },
              onInputValidated: (bool value) {
                _bloc.setPhoneNumberField = true;
                setState(() {
                  _validPhone = true;
                });
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: false,
              hintText: "Optional (in case of OTP)",
              autoValidateMode: AutovalidateMode.onUserInteraction,
              selectorTextStyle: TextStyle(color: Colors.black),
              textFieldController: _phoneNumberController,
              formatInput: false,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputBorder: OutlineInputBorder(),
            ),

            //UserName field
            StreamBuilder<String>(
                stream: _bloc.userNameStream,
                builder: (context, snapshot) {
                  return _userNameField(context, snapshot);
                }),

            Padding(
              padding: EdgeInsets.only(top: 25),
            ),

            //Text("Make sure you not forget this password!\nOtherwise you will lose your notes!"),

            //Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordRegistrationStream,
              builder: (context, snapshot) {
                return passwordField(context, snapshot);
              },
            ),

            Padding(
              padding: EdgeInsets.only(top: 25),
            ),

            //Repeat Password Field
            StreamBuilder<String>(
              stream: _bloc.passwordRepeatStream,
              builder: (context, snapshot) {
                return repeatPasswordField(context, snapshot);
              },
            ),

            Padding(
              padding: EdgeInsets.only(top: 25),
            ),

            //Add some padding
            Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("SMS OTP"),
                Padding(
                  padding: EdgeInsets.only(right: 50),
                ),
                Text("Fingerprint"),
                Padding(
                  padding: EdgeInsets.only(right: 50),
                ),
                Text("Password"),
              ],
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Checkbox(
                value: _smsOtp,
                onChanged: (value) async {
                  setState(() {
                    _smsOtp = !_smsOtp;
                    print(value);
                    //_initPlatformState();
                  });
                  await options.setOptions(sms: _smsOtp);
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 50),
              ),
              Checkbox(
                /*title: Text("Fingerprint Log In",
                      style: TextStyle(fontWeight: FontWeight.bold),),*/
                value: _finger,
                onChanged: (value) async {
                  setState(() {
                    _finger = !_finger;
                    print(value);
                  });
                  await options.setOptions(finger: _finger);
                  if(_finger){
                      CanAuthenticateResponse response = await _checkAuthenticate();
                      if(CanAuthenticateResponse.success != response){
                        String dialogMessage = solveBioAuth(response);
                        _showDialog("Cannot use the fingerprint", dialogMessage);
                        setState(() {
                          _finger = false;
                        });
                      await options.setOptions(finger: _finger);
                      }
                    
                  } 
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 40, left: 20),
              ),
              Checkbox(
                /*title: Text("Password Log In",
                      style: TextStyle(fontWeight: FontWeight.bold),),*/
                value: _password,
                onChanged: (value) async {
                  setState(() {
                    _password = !_password;
                    print(value);
                  });
                  await options.setOptions(password: _password);
                },
              ),
            ]),

            //Register BUTTON
            StreamBuilder<bool>(
                stream: _bloc.registerValid,
                builder: (context, snapshot) {
                  return _registerButton(snapshot);
                }),

            //Add some padding
            Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),

            //CAPTCHA
            recaptchaButton(),
          ],
        ),
      ),
    );
  }

  Widget _userNameField(BuildContext context, dynamic snapshot) {
    return TextField(
      controller: _userNameController,
      decoration: InputDecoration(
        labelText: 'User Name',
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
        _bloc.passwordRegistrationOnChange(value);
      },
    );
  }

  Widget repeatPasswordField(BuildContext context, dynamic snapshot) {
    return TextField(
      enableSuggestions: false,
      autocorrect: false,
      obscureText: true,
      controller: _passRepeatController,
      decoration: InputDecoration(
        labelText: 'Repeat Password',
        errorText: snapshot.error,
      ),
      onChanged: (String value) {
        _bloc.passwordRepeatOnChange(value);
      },
    );
  }

  Widget _registerButton(AsyncSnapshot snap) {
    return StreamBuilder(
      stream: _timerStream.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return SizedBox(
            width: 300,
            height: 30,
            child: RaisedButton(
              textColor: Theme.of(context).accentColor,
              child: Center(
                  child: _validationCond(snapshot, snap)
                      ? Text('Register')
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                ' Resend OTP in ${snapshot.hasData ? snapshot.data.toString() : 30} seconds '),
                          ],
                        )),
              onPressed: _validationCond(snapshot, snap)
                  ? () {
                      setState(() {
                        _init = false;
                      });
                      _onPressRegister();
                    }
                  : null,
            ));
      },
    );
  }

  _validationCond(snapshot, snap) {
    if (_finger || _password) {
      if (!_smsOtp && _finger && !_password) {
        return true;
      }
      if (_finger && _smsOtp && !_password) {
        return _validPhone;
      }
      if (_password && _smsOtp) {
        return (_init || snapshot.data == 0) &&
            (snap.hasData && snap.data) &&
            _validPhone;
      } else {
        return (_init || snapshot.data == 0) && (snap.hasData && snap.data);
      }
    }
    return false;
  }

  Widget recaptchaButton() {
    return Stack(children: <Widget>[
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Show that you are not a bot"),
            RaisedButton(
              child: Text(_bloc.getVerifyText),
              color: Colors.black38,
              textColor: Colors.white,
              disabledColor: Colors.lightGreenAccent,
              disabledTextColor: Colors.white,
              onPressed: () {
                if (!_bloc.getVerify)
                  return _goToCaptchaScreen(context);
                else
                  return null;
              },
            ),
          ],
        ),
      )
    ]);
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

  _onPressRegister() async {
    //Check if the user has verified the CAPTCHA
    var registered = await _bloc.isRegistered();
    if (_bloc.getVerify && !registered) {
      //bool safeNet = await _requestSafetyNetAttestation();
      /*if (safeNet)*/ await _registerUser();
    } else if (registered) {
      _showDialog(
          'Registration Failed', "You are already registered in this notebook");
    } else{
      _showDialog('Click the I am not a robot button',
          "You have not verified the captcha"); //Show the not verified alertDialog
        setState(() {
          _init = true;
        });}
  }

  _registerUser() async {
    if (options.smsOTP) {
      AuthResult auth = await AuthProvider.authPhone(_bloc.getPhone, context);
      if (auth != null) {
        if (auth.result) {
          _clearSignUp();
          _bloc.register();
          _goToSuccessRegistration(context);
          return;
        } else {
          _showDialog("Registration Failed!", auth.message);
          _timerStream.sink.add(30);
          _activeCounter();
          return;
        }
      } else {
        _showDialog("Registration Failed!",
            "Some error occurred during registration, try again!");
        _timerStream.sink.add(30);
        _activeCounter();
        return;
      }
    } else
      await _bloc.register();
      _goToSuccessRegistration(context);
    return;
  }

  _goToSuccessRegistration(context) {
    String message = options.logInByFinger ? "fingerprint" : "password";
    message = message + (options.logInByPassword ? " and password" : "");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterScreen(method: message)));
  }

  _goToCaptchaScreen(context) {
    var captcha = CaptchaPage();
    captcha.setBloc(_bloc);
    Navigator.push(context, MaterialPageRoute(builder: (context) => captcha));
  }

  _clearSignUp() {
    _phoneNumberController.clear();
    _passController.clear();
    _passRepeatController.clear();
    _userNameController.clear();
  }
}
