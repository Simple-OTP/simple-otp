import 'dart:convert';
import 'dart:core';

/// The model that represents a OTP Secret.
class OTPSecret implements Comparable<OTPSecret> {
  final String issuer;
  final String username;
  final String secret;
  num timestamp;

  OTPSecret(
      {required this.issuer,
      required this.username,
      required this.secret,
      num? timestamp})
      : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// List of secrets to json
  static String writeToJSON(List<OTPSecret> secrets) {
    return jsonEncode({"codes": secrets});
  }

  /// List of secrets from json
  static List<OTPSecret> readFromJson(String jsonString) {
    try {
      final jsonDecoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final parsed = jsonDecoded['codes'] as List<dynamic>;
      final list =
          parsed.map<OTPSecret>((json) => OTPSecret.fromJson(json)).toList();
      list.sort();
      return list;
    } catch (e) {
      // If encountering an error, return 0
      throw ("Could not read json");
    }
  }

  OTPSecret.fromJson(Map<String, dynamic> json)
      : issuer = json['issuer'] as String,
        username = json['username'] as String,
        secret = json['secret'] as String,
        timestamp = json.containsKey('timestamp')
            ? json['timestamp'] as num
            : DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'issuer': issuer,
        'username': username,
        'secret': secret,
        'timestamp': timestamp,
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
