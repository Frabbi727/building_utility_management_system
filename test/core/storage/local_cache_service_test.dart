import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox mockBox;
  late LocalCacheService serviceWithBox;
  late LocalCacheService uninitializedService;

  setUp(() {
    mockBox = MockBox();
    serviceWithBox = LocalCacheService(box: mockBox);
    uninitializedService = LocalCacheService();
  });

  group('LocalCacheService uninitialized fail-fast', () {
    test('get throws CacheException when uninitialized', () {
      expect(
        () => uninitializedService.get<String>('key'),
        throwsA(isA<CacheException>()),
      );
    });

    test('put throws CacheException when uninitialized', () async {
      expect(
        () => uninitializedService.put<String>('key', 'value'),
        throwsA(isA<CacheException>()),
      );
    });

    test('delete throws CacheException when uninitialized', () async {
      expect(
        () => uninitializedService.delete('key'),
        throwsA(isA<CacheException>()),
      );
    });

    test('clearAll throws CacheException when uninitialized', () async {
      expect(
        () => uninitializedService.clearAll(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('LocalCacheService initialized operations', () {
    test('get returns cached value when key exists', () {
      when(() => mockBox.get('test_key', defaultValue: any<dynamic>(named: 'defaultValue')))
          .thenReturn('cached_value');

      final result = serviceWithBox.get<String>('test_key');

      expect(result, equals('cached_value'));
      verify(() => mockBox.get('test_key', defaultValue: null)).called(1);
    });

    test('get returns defaultValue when key does not exist', () {
      when(() => mockBox.get('test_key', defaultValue: 'default'))
          .thenReturn('default');

      final result = serviceWithBox.get<String>('test_key', defaultValue: 'default');

      expect(result, equals('default'));
      verify(() => mockBox.get('test_key', defaultValue: 'default')).called(1);
    });

    test('getInt delegates to get<int>', () {
      when(() => mockBox.get('int_key', defaultValue: any<dynamic>(named: 'defaultValue')))
          .thenReturn(42);

      final result = serviceWithBox.getInt('int_key');

      expect(result, equals(42));
      verify(() => mockBox.get('int_key', defaultValue: null)).called(1);
    });

    test('put saves value into box', () async {
      when(() => mockBox.put('save_key', 'save_val'))
          .thenAnswer((_) async {});

      await serviceWithBox.put<String>('save_key', 'save_val');

      verify(() => mockBox.put('save_key', 'save_val')).called(1);
    });

    test('putInt delegates to put<int>', () async {
      when(() => mockBox.put('int_key', 42))
          .thenAnswer((_) async {});

      await serviceWithBox.putInt('int_key', 42);

      verify(() => mockBox.put('int_key', 42)).called(1);
    });

    test('delete removes key from box', () async {
      when(() => mockBox.delete('del_key'))
          .thenAnswer((_) async {});

      await serviceWithBox.delete('del_key');

      verify(() => mockBox.delete('del_key')).called(1);
    });

    test('clearAll clears box', () async {
      when(() => mockBox.clear())
          .thenAnswer((_) async => 0);

      await serviceWithBox.clearAll();

      verify(() => mockBox.clear()).called(1);
    });
  });
}
