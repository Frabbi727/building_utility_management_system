import 'package:building_utility_management_system/features/auth/data/models/auth_response_model.dart';
import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:building_utility_management_system/shared/data/models/flat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = UserModel(
    id: 'user-123',
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  const flat = FlatModel(
    id: 1,
    number: 'A-101',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  const model = AuthResponseModel(
    token: 'sanctum-token-xyz',
    user: user,
    flats: [flat],
  );

  final jsonMap = <String, dynamic>{
    'token': 'sanctum-token-xyz',
    'user': <String, dynamic>{
      'id': 'user-123',
      'name': 'Jane Doe',
      'email': 'jane@example.com',
      'phone': null,
      'is_owner': null,
      'is_tenant': null,
    },
    'flats': [
      <String, dynamic>{
        'id': 1,
        'number': 'A-101',
        'floor': '1st',
        'building_id': 10,
        'building_name': 'Tower A',
      },
    ],
  };

  test('AuthResponseModel fromJson deserializes correctly with flats', () {
    final result = AuthResponseModel.fromJson(jsonMap);
    expect(result, equals(model));
    expect(result.token, equals('sanctum-token-xyz'));
    expect(result.user, equals(user));
    expect(result.flats.length, equals(1));
    expect(result.flats.first, equals(flat));
  });

  test('AuthResponseModel fromJson defaults flats to empty list when omitted', () {
    final mapWithoutFlats = <String, dynamic>{
      'token': 'sanctum-token-xyz',
      'user': <String, dynamic>{
        'id': 'user-123',
        'name': 'Jane Doe',
        'email': 'jane@example.com',
      },
    };
    final result = AuthResponseModel.fromJson(mapWithoutFlats);
    expect(result.flats, isEmpty);
  });

  test('AuthResponseModel toJson serializes correctly', () {
    final result = model.toJson();
    expect(result, equals(jsonMap));
  });

  test('AuthResponseModel equality works based on props', () {
    const model2 = AuthResponseModel(
      token: 'sanctum-token-xyz',
      user: user,
      flats: [flat],
    );
    expect(model, equals(model2));
  });
}
