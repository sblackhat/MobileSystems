import 'dart:math';
import 'dart:typed_data';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_safetynet_attestation/flutter_safetynet_attestation.dart';

/// Creates a hexdecimal representation of the given [bytes].
String formatBytesAsHexString(Uint8List bytes) {
  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

String solveMessage(e) {
  String message;
  switch (e.message) {
    case 'The SMS code has expired. Please re-send the verification code to try again':
      message = 'The SMS is no longer valid';
      break;
    case 'The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.':
      message = "Wrong OTP code";
      break;
    case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
      message = "Cannot stablish connection with the server";
      break;
    default:
      message = e.message;
  }
  return message;
}

/*Check if value only contains alphanumeric 
and this special characters!@#%\$&*~=() */
bool passwordMatcher(String value) {
  return new RegExp(r'^[a-zA-Z0-9!@#%\$&*~=() ]+$').hasMatch(value);
}

//Check if the userName contains only letters and numbers
bool userNameMatcher(String username) {
  return new RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
}

String solveResponse(JWSPayload response){
    if(response.basicIntegrity)
      return "Your device has an unlocked bootloader or custom ROM";
    else return "Emulated device or rooted device";
}

List<int> generateRandomKey([int length = 32]) {
  final Random _random = Random.secure();
  var values = List<int>.generate(length, (i) => _random.nextInt(256));
  return values;
}

String solveBioAuth(CanAuthenticateResponse response){
  switch(response){
    case(CanAuthenticateResponse.errorHwUnavailable):
      return "Biometric sensor not available right now. Try again later";
    case(CanAuthenticateResponse.errorNoBiometricEnrolled):
      return "No fingerprint enrolled. Go to settings!";
    case(CanAuthenticateResponse.errorNoHardware):
      return "Your device does not support biometric authentication";
    default:
    return "Error while trying to use the biometrics. Try again later.";
  }

}
