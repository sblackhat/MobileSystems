import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../validator/user_input_validator.dart';
import '../validator/validator_helpers.dart';

class ChangeUser extends StatefulWidget {
  @override
  _ChangeUserState createState() => _ChangeUserState();
}

class _ChangeUserState extends State<ChangeUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newUsername = TextEditingController();

  String _userNameValidator(String username) {
    if (username == null || username.isEmpty) {
      return ('Empty field');
    } else if (!userNameMatcher(username)){
      return ('Enter a valid username');
    }else {
      return null;
    }
  }

    Future<void> _validateInputs() async {
    if (_formKey.currentState.validate()) {
      String username = _newUsername.text;
      Validator.registerUserName(username: username);
      _showResult("Username successfuly changed", "Your new username is: $username");
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
                  child: Text("New username",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              Center(
                child: TextFormField(
                 decoration: const InputDecoration(
              icon : Icon(Icons.person),
              hintText: 'Choose an alphanumeric username',
              labelText: 'UserName'),
              validator: _userNameValidator,
              controller: _newUsername,
              maxLength: 20,
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

  void dispose(){
    super.dispose();
    _newUsername.clear();
  }
}
