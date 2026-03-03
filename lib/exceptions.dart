/// Base class for all Simple OTP exceptions.
class SimpleOtpException implements Exception {
  final String message;
  const SimpleOtpException(this.message);

  @override
  String toString() => message;
}

/// The database file could not be decrypted — likely a wrong password.
class BadPasswordException extends SimpleOtpException {
  const BadPasswordException() : super('Bad Password.');
}

/// The database file is structurally invalid and cannot be parsed.
class DatabaseCorruptedException extends SimpleOtpException {
  const DatabaseCorruptedException() : super('Database file is corrupted.');
}

/// The database file could not be read from disk.
class DatabaseReadException extends SimpleOtpException {
  const DatabaseReadException() : super('Could not read internal database.');
}

/// The decrypted JSON could not be parsed into secrets.
class DatabaseParseException extends SimpleOtpException {
  const DatabaseParseException() : super('Could not read json.');
}

/// An operation was attempted before the database was initialized.
class DatabaseNotInitializedException extends SimpleOtpException {
  const DatabaseNotInitializedException() : super('Database not initialized.');
}
