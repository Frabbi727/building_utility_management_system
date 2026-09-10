import 'package:building_utility_management_system/shared/data/models/flat_model.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlatEntity', () {
    const entity = FlatEntity(
      id: 1,
      number: '101',
      floor: '1st',
      buildingId: 2,
      buildingName: 'Green Tower',
    );

    test(r'displayName returns formatted string "$number • $buildingName"', () {
      expect(entity.displayName, equals('101 • Green Tower'));
    });

    test('supports value equality via Equatable', () {
      const entity2 = FlatEntity(
        id: 1,
        number: '101',
        floor: '1st',
        buildingId: 2,
        buildingName: 'Green Tower',
      );
      expect(entity, equals(entity2));
    });
  });

  group('FlatModel', () {
    const model = FlatModel(
      id: 1,
      number: '101',
      floor: '1st',
      buildingId: 2,
      buildingName: 'Green Tower',
    );

    const jsonMap = <String, dynamic>{
      'id': 1,
      'number': '101',
      'floor': '1st',
      'building_id': 2,
      'building_name': 'Green Tower',
    };

    test('fromJson deserializes correctly from json map', () {
      final result = FlatModel.fromJson(jsonMap);
      expect(result, equals(model));
    });

    test('toJson serializes correctly to json map', () {
      final result = model.toJson();
      expect(result, equals(jsonMap));
    });

    test('toEntity maps to FlatEntity correctly', () {
      final entity = model.toEntity();
      expect(
        entity,
        equals(const FlatEntity(
          id: 1,
          number: '101',
          floor: '1st',
          buildingId: 2,
          buildingName: 'Green Tower',
        )),
      );
      expect(entity.displayName, equals('101 • Green Tower'));
    });

    test('supports value equality via Equatable', () {
      const model2 = FlatModel(
        id: 1,
        number: '101',
        floor: '1st',
        buildingId: 2,
        buildingName: 'Green Tower',
      );
      expect(model, equals(model2));
    });
  });
}
