import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../validator/validator_helpers.dart';

class AuthResult{
  String message;
  bool result;

  AuthResult({String message, bool result}){
    this.message = message;
    this.result = result;
  }
}

class AuthProvider{

  static Future<AuthResult> authPhone(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 30),
        verificationCompleted: (AuthCredential authCredential) async {
          await _auth.signInWithCredential(authCredential);
          return new AuthResult(result: true, message: mobile); //Clear the UI details
        },
        verificationFailed: (FirebaseAuthException authException) {
          return new AuthResult(result: false, message: authException.message);
        },
        codeSent: (String verID, int forceResendingToken) =>
            _codeSent(mobile, verID, context,forceResendingToken),
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Timeout");
        });
  }

  static _codeSent(String mobile, String verificationId, BuildContext context, [int forceResendingToken]) {
    //show dialog to take input from the user
    final TextEditingController _codeController = new TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
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
                      // Sign the user in with the credential
                      new AuthResult(result: true, message: mobile);
                    } catch (e) {
                      String message = solveMessage(e);
                      return new AuthResult(message: message, result: false);
                    }
                  },
                )
              ],
            ));
  }
}



