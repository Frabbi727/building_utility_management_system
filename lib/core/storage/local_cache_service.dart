import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_keys.dart';

class LocalCacheService {
  Box<dynamic>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(StorageKeys.appBox);
  }

  T? get<T>(String key, {T? defaultValue}) {
    return _box?.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> put<T>(String key, T value) async {
    await _box?.put(key, value);
  }

  Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  Future<void> clearAll() async {
    await _box?.clear();
  }
}
