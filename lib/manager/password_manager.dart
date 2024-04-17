import 'package:cryptography/cryptography.dart';
import 'package:simple_otp/provider/configuration.dart';

PasswordManager get passwordManager => PasswordManager.instance;

class PasswordManager {
  PasswordManager._() : super();
  static final instance = PasswordManager._();

  /// OWASP approved: Argon2id "m=12288 (12 MiB), t=3, p=1" from https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  /// on March 24, 2024
  /// Upped the iterations to 4 for a bit of future proofing. Will need to
  /// eventually store the configuration so we can upgrade later.
  Future<SecretKey> generateFromPassword(String password) async {
    final algorithm = Argon2id(
      parallelism: 1,
      memory: 12000, // 12 000 x 1kB block = 12 MB
      iterations: 4,
      hashLength: 32,
    );
    return await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: Configuration.instance.nonce(),
    );
  }
}
