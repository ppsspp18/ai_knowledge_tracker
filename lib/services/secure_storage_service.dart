// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveCredentials(String endpoint, String apiKey, String model) async {
    await _storage.write(key: 'api_endpoint', value: endpoint);
    await _storage.write(key: 'api_key', value: apiKey);
    await _storage.write(key: 'selected_model', value: model);
  }

  Future<Map<String, String?>> getCredentials() async {
    return {
      'api_endpoint': await _storage.read(key: 'api_endpoint'),
      'api_key': await _storage.read(key: 'api_key'),
      'selected_model': await _storage.read(key: 'selected_model'),
    };
  }

  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}