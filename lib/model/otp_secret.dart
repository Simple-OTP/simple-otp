import 'dart:core';

/// The model that represents a OTP Secret.
class OTPSecret implements Comparable<OTPSecret> {
  final String issuer;
  final String username;
  final String secret;

  OTPSecret(
      {required this.issuer, required this.username, required this.secret});

  OTPSecret.fromJson(Map<String, dynamic> json)
      : issuer = json['issuer'] as String,
        username = json['username'] as String,
        secret = json['secret'] as String;

  Map<String, dynamic> toJson() => {
        'issuer': issuer,
        'username': username,
        'secret': secret,
      };

  @override
  String toString() {
    return 'OTPSecret{issuer: $issuer, username: $username}';
  }

  /// Sorts the list of OTPSecrets by issuer and username.
  @override
  int compareTo(OTPSecret other) {
    int result = issuer.compareTo(other.issuer);
    if (result == 0) {
      result = username.compareTo(other.username);
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OTPSecret &&
          runtimeType == other.runtimeType &&
          issuer == other.issuer &&
          username == other.username;

  @override
  int get hashCode => issuer.hashCode ^ username.hashCode;
}
