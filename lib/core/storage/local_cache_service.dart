import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_keys.dart';
import '../error/exceptions.dart';

class LocalCacheService {
  Box<dynamic>? _box;

  // ignore: prefer_initializing_formals
  LocalCacheService({Box<dynamic>? box}) : _box = box;

  Box<dynamic> get _activeBox =>
      _box ??
      (throw const CacheException(
        'LocalCacheService is not initialized. Call init() before accessing storage.',
      ));

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(StorageKeys.appBox);
  }

  T? get<T>(String key, {T? defaultValue}) {
    return _activeBox.get(key, defaultValue: defaultValue) as T?;
  }

  int? getInt(String key, {int? defaultValue}) {
    return get<int>(key, defaultValue: defaultValue);
  }

  Future<void> put<T>(String key, T value) async {
    await _activeBox.put(key, value);
  }

  Future<void> putInt(String key, int value) async {
    await put<int>(key, value);
  }

  Future<void> delete(String key) async {
    await _activeBox.delete(key);
  }

  Future<void> clearAll() async {
    await _activeBox.clear();
  }
}
