import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const model = UserModel(
    id: 'user-123',
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  const jsonMap = <String, dynamic>{
    'id': 'user-123',
    'name': 'Jane Doe',
    'email': 'jane@example.com',
  };

  test('UserModel fromJson deserializes correctly', () {
    final result = UserModel.fromJson(jsonMap);
    expect(result, equals(model));
  });

  test('UserModel toJson serializes correctly', () {
    final result = model.toJson();
    expect(result, equals(jsonMap));
  });

  test('UserModel toEntity maps to UserEntity', () {
    final entity = model.toEntity();
    expect(
      entity,
      equals(const UserEntity(
        id: 'user-123',
        name: 'Jane Doe',
        email: 'jane@example.com',
      )),
    );
  });

  test('UserModel equatable props equality', () {
    const model2 = UserModel(
      id: 'user-123',
      name: 'Jane Doe',
      email: 'jane@example.com',
    );
    expect(model, equals(model2));
  });
}
