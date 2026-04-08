import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _keyUserId = 'user_id';
  String? _cachedUserId;

  Future<String> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;
    
    // For now, hardcode "admin_user" as requested.
    // In the future, we can add real authentication here.
    String id = 'admin_user';
    await _storage.write(key: _keyUserId, value: id);
    
    _cachedUserId = id;
    return id;
  }
}
