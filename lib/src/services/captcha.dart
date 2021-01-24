import 'package:MobileSystems/src/bloc/bloc_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';

class CaptchaPage extends StatefulWidget {
  CaptchaPage({Key key, this.title}) : super(key: key);

  // ignore: avoid_init_to_null
  SignUpBloc _b = null;
  final String title;

  @override
  _CaptchaState createState() => _CaptchaState(_b);

  void setBloc(SignUpBloc bloc) {
    _b = bloc;
  }
}

class _CaptchaState extends State<CaptchaPage> {

  _CaptchaState(this._bloc);
  String _verifyText = "Not verified yet";

  final SignUpBloc _bloc;
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CAPTCHA"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("SHOW ReCAPTCHA"),
                  onPressed: () {
                    recaptchaV2Controller.show();
                  },
                ),
                Text(_verifyText),
              ],
            ),
          ),
          RecaptchaV2(
            apiKey: "6LeCwZYUAAAAAJo8IVvGX9dH65Rw89vxaxErCeou",
            apiSecret: "6LeCwZYUAAAAAKGahIjwfOARevvRETgvwhPMKCs_",
            controller: recaptchaV2Controller,
            onVerifiedError: (err){
              print(err);
            },
            onVerifiedSuccessfully: (success) {
              setState(() {
                if (success) {
                  _bloc.setVerify = true;
                  _verifyText = "You have been verified!!";
                  _bloc.setVerifyText = "You are not a robot";
                } else {
                  _bloc.setVerify = false;
                  _bloc.setVerifyText = "Show ReCAPTCHA";
                  _verifyText = "Try again to verify!";
                }
              });
            },
          ),
        ],
      ),
    );
  }
}