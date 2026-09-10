import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const model = UserModel(
    id: 'user-123',
    name: 'Jane Doe',
    email: 'jane@example.com',
    phone: '01700000000',
    isOwner: true,
    isTenant: false,
  );

  const jsonMap = <String, dynamic>{
    'id': 'user-123',
    'name': 'Jane Doe',
    'email': 'jane@example.com',
    'phone': '01700000000',
    'is_owner': true,
    'is_tenant': false,
  };

  test('UserModel fromJson deserializes correctly with string id', () {
    final result = UserModel.fromJson(jsonMap);
    expect(result, equals(model));
  });

  test('UserModel fromJson safely parses integer id into string', () {
    final mapWithIntId = <String, dynamic>{
      'id': 123,
      'name': 'Jane Doe',
      'email': 'jane@example.com',
    };
    final result = UserModel.fromJson(mapWithIntId);
    expect(result.id, equals('123'));
  });

  test('UserModel fromJson safely handles null id', () {
    final mapWithNullId = <String, dynamic>{
      'id': null,
      'name': 'Jane Doe',
      'email': 'jane@example.com',
    };
    final result = UserModel.fromJson(mapWithNullId);
    expect(result.id, equals(''));
  });

  test('UserModel toJson serializes correctly', () {
    final result = model.toJson();
    expect(result, equals(jsonMap));
  });

  test('UserModel toEntity maps to UserEntity with optional fields', () {
    final entity = model.toEntity();
    expect(
      entity,
      equals(const UserEntity(
        id: 'user-123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '01700000000',
        isOwner: true,
        isTenant: false,
      )),
    );
  });

  test('UserModel equatable props equality', () {
    const model2 = UserModel(
      id: 'user-123',
      name: 'Jane Doe',
      email: 'jane@example.com',
      phone: '01700000000',
      isOwner: true,
      isTenant: false,
    );
    expect(model, equals(model2));
  });
}
