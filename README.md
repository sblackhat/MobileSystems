# MobileSystems

The project is fully written on flutter. It consists of a simple notebook app which its contents are encrypted using the log in method of the user.
It can be a password or the biometrics. The password is stored used the scrypt algorithm so we are only storing the hashed password and we are goning to 
compare it when the users tries to log in. This password should be at least 20 characters long in order to be secure.

The fingerprint works in a similar way, if the user is only using the fingerprint to log in, the app generates a random 256 bit key password which is encrypted using
the biometrics. The encryption is provided by the biometric_storage extension in flutter. However, whenever the user configures the app to use also the password encryption,
the DB reencryption is performed and the random key does not longer encrypt the notes, the user's password is used.

Both methods, rely on Hive extension to store and encrypt the notes. This extension is using AES-256 bit CBC mode encryption.

The OTP is managed using the FireBase Authentication provided by Google, which let us to integrate the SMS verification for free with some limitations.

Another layer of security that is used is the recaptcha v2 that is used in the registration process, that verifies if the user is not a robot.

