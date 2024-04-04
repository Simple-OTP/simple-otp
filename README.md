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

## CI/CD

https://docs.flutter.dev/deployment/cd

## Packaging

### debian

https://pub.dev/packages/flutter_to_debian