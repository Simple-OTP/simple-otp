# Simple OTP

Now that Authy no longer has a desktop application, planning on creating a way 
to do this easily from the stored set of secrets.

Using rust for the application. End goal will be a simple UI where you can 
enter the secrets. They will be stored locally in a JSON file, encrypted with 
your passphrase. (Or use gpg to encrypt the file, still trying to decide.)

Adding a UI with a count-down timer because that's fun.

## Status
![SimpleOTP Build](https://github.com/wolpert/simple_otp/actions/workflows/simple_otp_build.yml/badge.svg)

## Description

With the Authy desktop application going away, there is a need for a
simple but secure OTP generator that is not tied to the company with
the 2FA requirement, like google or Bitwarden. This was designed to be
a minimalist project but with the ability to import/export.

Uses flutter/dart so the project will work across all major devices.
Starting with Linux/Android.

## Flow

The application has a basic flow. Unlock your database, add/remove
authentication secrets, and generate code for secrets you
select. Codes are regenerated when the current one expires. Can add to
the clipboard.

There is no cloud save. You can export/import files. Some point in the
future I may do a device/device communications to sync devices.

Your authentication secrets are encrypted with AES/GCM using a 256-bit
key derived from your password.

## UI

![UI Flow](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=SimpleOTPWireFrame.drawio#R7VrRjto6EP0aHoschyTwuMC2V9VWWhVV975VJjGJu06MHLNAv%2F6OwSExDoV2NyytitDijMeOc%2BZ4PDPZnj%2FJNx8kWWafREJ5D6Nk0%2FOnPYw9z0PwoyXbvSTyo70glSwxSrVgxr5TIzTj0hVLaGkpKiG4YktbGIuioLGyZERKsbbVFoLbd12SlDqCWUy4K%2F2XJSrbS4cBquX%2FUJZm1Z09ZHpyUikbQZmRRKwbIv%2B%2B50%2BkEGrfyjcTyjV4FS77ce9P9B4WJmmhLhkQBd9SEX%2F0v6p3T5uPwXzK77fvzCzPhK%2FMA5vFqm2FgBSrIqF6EtTzx%2BuMKTpbklj3rsHmIMtUzuHKg6aZjkpFNyfX6R2eHmhDRU6V3IKKGTAweG3ty3WNPvaNLGsiHxohMRZPDzPXoEDD4PITGGEHo0dSlmshEwcreGplA0I4Swtox%2FD0VIJAY8OAX3emI2dJooe3Imtj%2Fwrgejiw0A1ddMMWcP2usPVvkH82QqMW%2FuFrQhQ4EH0puIif3hwojGykPP8yMuGukAodpD7Tkqo3B2pwYzhF5zcdHFZL3VxwurnTxyggQYvENKcxBw%2FIYhupNmdFE%2Bd4PYtaA5agBZZKJiknij3b07dhZe7wKBjcuGbvyD5nvGO4S7GSMTWjmufq0UR%2BdGYiRWRKlTPRznSHx%2F51aw5vz4X6o7Nn%2BAC1Mr4ryo8ckO5WsBSMJkKHlw791yznpNDH8kIUamZ6NHpxxnjyQLZipRddKhI%2FVVfjTEj2HfRJhSV0S2WCWh9ZGjM90swpaQk6jxW%2B3pHoE9lYig%2BkVNVqBOdkWbL5bn16YA5sY8VYKCXyWzK4F7UFbZ35uCp%2FaFh8RuUziyk8CYByB3%2B%2FlBCRYeQ55jdhXKmkeKITwQUEbtNC7PnAOD8SVTEepwv1owivBBOwIn3YqU0HteSzQUSLBAxf8J2XzWAghRnGS%2B07dggFY%2FjCo01QP%2BgFsNYJXHv1NXy1ulQTUcDyCdvZjwJh1lSTBpy0IorMD3R%2BDW6c3nEuYbZ2tHSOIJ1FVZ6b%2BZzih%2BtP%2F%2FKja3605CVX5oeb9Rl%2B4L%2F%2B4%2B350ZKVXZkfN5i5Hp%2FCh3DqXNw16AylQQtKIddEmkMj1Q0dgVVCuMlBfmpX3W5xJQxs%2FIORA%2F9ViyueWzrwsD8Iwt8f2uFbQ%2BvWGhxQG%2FmycfQnk2X7pOhhH0%2BjEOmeb6t8aRII7B8dH6AXIjLyosMMVYl68Bsk4OFRodfzRvYUlybgET4zUccJuHdBPaVh%2BWojPZA55Y%2BiZIoJvaHmJmU7MiVuowdCQ%2FQeHdHB0hofXjdotYSUWU02U9vJN6l%2BZ9Nnooz6LIYDvw%2FZKZCD6BV93dUYTexA5f0z3YcQVdz8kt0cRMP%2BUVEMo1E%2FcPY09vto1PwMXTr%2BiHkvq%2Fu7KeSL7Oq4VK41xyR%2BSnfeoGHfxe7T4nWVWP4kQ36JByRJXsdvB%2BHZwkDby5zO%2FHZlwktqnxUuOWyE1bKfE6l%2FJE3%2Bc%2F3wYoHQzl83CGEh33ZKtuYHHYDeVnBue4XRWTEGXxAs%2F3mot0Tf10W9Lfj%2B01EfdgY6XNYv6%2FexQ%2F0vD%2F79%2Fw%3D%3D)

### Unlock Screen
#### Use password to unlock
#### Biometrics to unlock
#### Pin to unlock
### Code Selector Screen
#### Add Dialog Box
#### Remove Dialog Box
#### Lock button
### Preferences
#### Add/remove biometrics
#### Add/remove pin
#### import/export (option: decrypted)

# Github Actions

If you change the workflow files such as `.github/workflows/flutter.yml`, 
run 'gh act' to verify the changes. 

To install act, see here: https://github.com/nektos/act/blob/master/README.md (I picked the github extension install)

# Dev notes

Always run `make` at the top level before creating your commit.

## Adding mocks

After adding new mocks to be generated,
run

```bash
dart run build_runner build
```

This is done automatically if you use the top-level Makefile.

