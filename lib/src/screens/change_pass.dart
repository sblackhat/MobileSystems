import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../validator/validator_helpers.dart';
import '../validator/user_input_validator.dart';

class ChangePass extends StatefulWidget {
  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _passwordRepeat = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  var _passwordRepeatValidator;

  String _passwordValidator(String password) {
    if (password == null || password.isEmpty) {
      return ('Empty field');
    } else if (!passwordMatcher(password)){
      return ('Special characters allowed !@#%\$&*~=()');
    }else if (password.length < 20){
      return ("The password should at least be 20 characters long");
    }else{
      return null;}
  }

    String _passwordRValidator(String password) {
    if (password == null || password.isEmpty) {
      return ('Empty field');
    }else if (_newPassword.text.isEmpty){
      return("New password field is empty");
    } else if (!(password == _newPassword.text)){ 
      return("The passwords do not match");
    }else return null;
  }
   String _passwordOValidator(String password) {
    if (password == null || password.isEmpty) {
      return ('Empty field');
    }else return null;
  }

    Future<void> _validateInputs() async {
    if (_formKey.currentState.validate()) {
      var result = await Validator.validatePassword(_oldPassword.text);
      if(result){
      final String password = _newPassword.text;
      Validator.registerUserName(password: password);
      _showResult('Password sucessfully changed', 'You have set a new password');
      _passwordRepeat.clear();
      _newPassword.clear();
      _oldPassword.clear();
      } else{
        _showResult("Password cannot be changed", "Wrong old password");
      }
    } 
    }

  _showResult(String title,String message){
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
      return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text('Secure Black Notebook')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Text("Change password",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              Center(
                child: TextFormField(
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                 decoration: const InputDecoration(
              icon : Icon(Icons.person),
              hintText: 'Old password',
              labelText: 'Old Password'),
              validator: _passwordOValidator,
              controller: _oldPassword,
              maxLength: 40,
              autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),

              
              Center(
                child: TextFormField(
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                 decoration: const InputDecoration(
              icon : Icon(Icons.person),
              hintText: 'Choose a new password',
              labelText: 'Password'),
              validator: _passwordValidator,
              controller: _newPassword,
              maxLength: 40,
              autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),

              Center(
                child: TextFormField(
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                 decoration: const InputDecoration(
              icon : Icon(Icons.person),
              hintText: 'Repeat the new password',
              labelText: 'Repeat Password'),
              validator: _passwordRValidator,
              controller: _passwordRepeat,
              maxLength: 40,
              autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),

              Center(
                child: RaisedButton(
                  onPressed: _validateInputs,
                  elevation: 0.0,
                  color: Colors.blue,
                  disabledColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    child: Text(
                      "Submit Changes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
