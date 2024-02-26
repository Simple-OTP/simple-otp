# Simple OTP

Now that Authy no longer has a desktop application, planning on creating a way 
to do this easily from the stored set of secrets.

Using rust for the application. End goal will be a simple UI where you can 
enter the secrets. They will be stored locally in a JSON file, encrypted with 
your passphrase. (Or use gpg to encrypt the file, still trying to decide.)

Adding a UI with a count-down timer because that's fun.

## Status

[![Makefile CI](https://github.com/wolpert/simple_otp/actions/workflows/rust.yml/badge.svg)](https://github.com/wolpert/simple_otp/actions/rust/makefile.yml)

# Install GTK3

## Ubunto
```bash
sudo apt-get install libgtk-3-dev
```

# Libraries in use
- [totp-rs](https://github.com/constantoine/totp-rs) for OTP generation
- [druid](https://github.com/linebender/druid) for the UI
