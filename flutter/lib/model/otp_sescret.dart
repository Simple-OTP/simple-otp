import 'dart:core';

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

  // sort by Name (asc)
  @override
  int compareTo(OTPSecret other) {
    int result = issuer.compareTo(other.issuer);
    if (result == 0) {
      result = username.compareTo(other.username);
    }
    return result;
  }
}
