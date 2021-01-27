import 'dart:async';
import 'dart:typed_data';
import 'package:MobileSystems/src/handlers/note_handler.dart';
import 'package:MobileSystems/src/options/user_options.dart';
import 'package:MobileSystems/src/validator/validator_helpers.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class Validator {
  static final _secure = FlutterSecureStorage();
  static final _derivator = KeyDerivator("scrypt");
  static final _derivator2 = KeyDerivator("scrypt");
  static final int _iterations = 256;
  static final int _blocksize = 8;
  static final int _paralelization = 1;
  static bool _init = false;

  //Initalize the Keyderivation function
  static init() async {
    //Memory required = 128 * N * r * p bytes
    //128 * 65536 * 8 * 1 = 2 MB
    String salt = await _getSalt();
    String salt2 = await _getSalt2();
    if (salt != null) {
      Uint8List bytes = Uint8List.fromList(salt.codeUnits);
      Uint8List bytes2 = Uint8List.fromList(salt2.codeUnits);
      //64 bytes hash lenght
      var params =
          ScryptParameters(_iterations, _blocksize, _paralelization, 32, bytes);
       var params2 =
          ScryptParameters(_iterations, _blocksize, _paralelization, 32, bytes2);

      //Init the key derivation function
      _derivator.init(params);
      _derivator2.init(params2);
    }
  }

  //Get the phone from the KeyStorage
  static Future<String> getPhone() async {
    String result = await _secure.read(key: "phone");
    return result;
  }

  static Future<bool> isRegisterPassword() async {
    return await _secure.containsKey(key: "password");
  }

  static String getRandom(){
    final rnd = new FortunaRandom()..seed(new KeyParameter(new Uint8List(32)));
    return rnd.toString();
  }

  //Returns the hashed password
  static Future<String> _getHashedPass(String password) async {
    Uint8List list = new Uint8List.fromList(password.codeUnits);
    final bytes = _derivator.process(list);
    return formatBytesAsHexString(bytes);
  }

  static Future<String> getUsername() async {
    return await _secure.read(key: "username");
  }

  static Future<String> _getSalt() async {
    return await _secure.read(key: "salt");
  }
  static Future<String> _getSalt2() async {
    return await _secure.read(key: "salt2");
  }

  static Future<bool> validatePassword(String password, {String username}) async {
    //Check if the password has any not allowed character and
    //validate the username of the user
    if (passwordMatcher(password)) {
      Validator.init();
      final hash = await _getHashedPass(password);
      final stored = await _secure.read(key: "password");
      final user =  await _secure.read(key: "username");
      //Check the stored hashed key and the input key
      if (stored != null && hash == stored && (username==null || username==user)) {
        if (!_init) {
          Uint8List key = _derivator2.process(new Uint8List.fromList(password.codeUnits));
          await NoteHandler.init(HiveAesCipher(key));
          _init = true;
        }
        return true;
      } else
        return false;
    } else
      return false;
  }

  validateFinger() async {
    final _authStorage = await BiometricStorage().getStorage("key");
    final key = await _authStorage.read();
    await NoteHandler.init(HiveAesCipher(Uint8List.fromList(key.codeUnits)));
  }

  /*
   Functions below are used in the registration process
                                                        */

  static Future<bool> _writePass(String password, {String username}) async {
    try{
    //Confirm the Bio if change the pass
    UserOptions options = new UserOptions();
    //Write new salt
    //Create a new salt every time the password changes
    final rnd = new FortunaRandom()..seed(new KeyParameter(new Uint8List(32)));
    final rnd2 = new FortunaRandom()..seed(new KeyParameter(new Uint8List(32)));
    //256 bit salt
    final bool reset = await _secure.containsKey(key: "salt");
    String salt = formatBytesAsHexString(rnd.nextBytes(32));
    String salt2 = formatBytesAsHexString(rnd2.nextBytes(32));
    //Store the salt
    await _secure.write(key: "salt", value: salt);
    await _secure.write(key: "salt2", value: salt2);
    //Init the cipher
    await Validator.init();
    //Get the passHash;
    final hashed = await Validator._getHashedPass(password);
    await _secure.write(key: "password", value: hashed);
    await _secure.write(key: "username", value: username);
    //Get the password for Hive
    List<int> key = _derivator2.process(new Uint8List.fromList(password.codeUnits));

    if(options.logInByFinger){
        final _authStorage = await BiometricStorage().getStorage("key");
        await _authStorage.write(String.fromCharCodes(key));
      }
    if(reset || (options.logInByFinger && !options.logInByPassword)){
      await NoteHandler.resetPass(HiveAesCipher(key));
    }
    return true;
    }catch (e){
      print(e.runtimeType);
      print(e);
      return false;
    }
  }

  static registerFingerprint() async {
    final _authStorage = await BiometricStorage().getStorage("key");
    await _authStorage.write(String.fromCharCodes(generateRandomKey()));
  }

  static Future<bool> isRegistered() {
    return _secure.containsKey(key: "username");
  }

  static Future<bool> logInFinger() async {
    try{
    final _authStorage = await BiometricStorage().getStorage("key");
    final key = await _authStorage.read();
    await NoteHandler.init(HiveAesCipher(key.codeUnits));
    return true;
    }catch(e){
      return false;
    }
  }

  static Future<bool> registerUserName(
      {String username, String password, String phone}) async {
    if (password != null) return await _writePass(password,username: username);
    if (username != null){
      try{
     _secure.write(key: "username", value: username);
     return true;
     }catch(e){
       return false;
     }
    }
    if (phone != null){
      try{
      _secure.write(key: "phone", value: phone);
     return true;
     }catch(e){
       return false;
     }
    }
    else await registerFingerprint();
  }
}
