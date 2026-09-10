import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  late MockLocalCacheService mockCache;
  late FlatContextService service;

  const flat1 = FlatEntity(
    id: 1,
    number: 'A-101',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );
  const flat2 = FlatEntity(
    id: 2,
    number: 'B-202',
    floor: '2nd',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  setUp(() {
    mockCache = MockLocalCacheService();
    when(() => mockCache.getInt(any())).thenReturn(null);
    when(() => mockCache.putInt(any(), any())).thenAnswer((_) async {});
    service = FlatContextService(cacheService: mockCache);
  });

  test('initialize with list selects first flat if no cache exists', () {
    service.initializeFlats([flat1, flat2]);

    expect(service.availableFlats.length, 2);
    expect(service.selectedFlat.value, equals(flat1));
    verify(() => mockCache.putInt('active_flat_id', 1)).called(1);
  });

  test('initialize restores cached flat if present in list', () {
    when(() => mockCache.getInt('active_flat_id')).thenReturn(2);
    service.initializeFlats([flat1, flat2]);

    expect(service.selectedFlat.value, equals(flat2));
  });

  test('initialize falls back to first flat if cached id is not in list', () {
    when(() => mockCache.getInt('active_flat_id')).thenReturn(999);
    service.initializeFlats([flat1, flat2]);

    expect(service.selectedFlat.value, equals(flat1));
    verify(() => mockCache.putInt('active_flat_id', 1)).called(1);
  });

  test('initialize with empty list sets selectedFlat to null', () {
    service.initializeFlats([]);

    expect(service.availableFlats.isEmpty, isTrue);
    expect(service.selectedFlat.value, isNull);
  });

  test('selectFlat updates selectedFlat and writes to cache', () {
    service.initializeFlats([flat1, flat2]);
    service.selectFlat(flat2);

    expect(service.selectedFlat.value, equals(flat2));
    verify(() => mockCache.putInt('active_flat_id', 2)).called(1);
  });

  test('clear resets selectedFlat to null and empties availableFlats', () {
    service.initializeFlats([flat1, flat2]);
    expect(service.selectedFlat.value, equals(flat1));

    service.clear();

    expect(service.selectedFlat.value, isNull);
    expect(service.availableFlats.isEmpty, isTrue);
  });
}
