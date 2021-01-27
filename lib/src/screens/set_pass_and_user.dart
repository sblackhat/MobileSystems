import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../validator/validator_helpers.dart';
import '../validator/user_input_validator.dart';
import '../options/user_options.dart';

class SetPassandUser extends StatefulWidget {
  @override
  _SetPassandUserState createState() => _SetPassandUserState();
}

class _SetPassandUserState extends State<SetPassandUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _passwordRepeat = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  var _passwordRepeatValidator;
  UserOptions options;

  @override
  initState(){
    super.initState();
    options = UserOptions.getInstance();
  }

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
   String _userNameValidator(String userName) {
    if (userName == null || userName.isEmpty) {
      return ('Empty field');
    }else if(!userNameMatcher(userName)) return("The username should be alphanumeric");
    else return null;
  }

    Future<void> _validateInputs() async {
    if (_formKey.currentState.validate()) {
      final String password = _newPassword.text;
      bool res = await Validator.registerUserName(password: password, username: _userName.text);
      if(res){
      _showResult('Log in by password set', 'You have set the login by password succesfuly');
      await options.setOptions(password: true);
      _passwordRepeat.clear();
      _newPassword.clear();
      _userName.clear();
      }else{
        _showResult("Registering user and password failed", "Try again");
      }
    } else{
        _showResult("Log in by password cannot be set", "Check the form fields.");
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
                  child: Text("Set new username & password",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              Center(
                child: TextFormField(
                 decoration: const InputDecoration(
              icon : Icon(Icons.person),
              hintText: 'Username',
              labelText: 'Username'),
              validator: _userNameValidator,
              controller: _userName,
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
              icon : Icon(Icons.lock),
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
              icon : Icon(Icons.lock),
              hintText: 'Repeat password',
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
