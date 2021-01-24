import 'package:shared_preferences/shared_preferences.dart';

class UserOptions {
  static bool _smsOTP = false;
  static bool _logInByPassword = false;
  static bool _logInByFinger = false;
  static SharedPreferences _prefs;
  static bool _init = false;

  UserOptions() {
    if(!_init)
    init();
  }

  static getInstance() async {
    await init();
    return UserOptions();
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    //Check if it is initalized the user settings
    if (!_prefs.containsKey("logInByPassword")) {
      await _prefs.setBool("logInByPassword", false);
      await _prefs.setBool("logInByFinger", false);
      await _prefs.setBool("smsOTP", false);
    }

    _logInByPassword = _prefs.getBool("logInByPassword");
    _logInByFinger = _prefs.getBool("logInByFinger");
    _smsOTP = _prefs.getBool("smsOTP");
    _init = true;
  }

  get smsOTP => _smsOTP;
  get logInByFinger => _logInByFinger;
  get logInByPassword => _logInByPassword;

  setOptions({bool password,bool finger, bool sms}) async {
    if(password != null){
      await _prefs.setBool("logInByPassword", password);
      _logInByPassword = password;
    }
    if(finger != null){
      await _prefs.setBool("logInByFinger", finger);
      _logInByFinger = finger;
    }
    if(sms != null){
      await _prefs.setBool("smsOTP", sms);
      _smsOTP = sms;
    }
  }
}
