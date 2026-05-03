import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final _auth = LocalAuthentication();
  Future<bool> authenticate() => _auth.authenticate(
    localizedReason: 'Authenticate to access vault',
    biometricOnly: true,
  );
}
