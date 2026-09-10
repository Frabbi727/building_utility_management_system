import 'package:building_utility_management_system/features/auth/data/models/auth_response_model.dart';
import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = UserModel(
    id: 'user-123',
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  const model = AuthResponseModel(
    accessToken: 'access-token-xyz',
    refreshToken: 'refresh-token-xyz',
    user: user,
  );

  final jsonMap = <String, dynamic>{
    'accessToken': 'access-token-xyz',
    'refreshToken': 'refresh-token-xyz',
    'user': <String, dynamic>{
      'id': 'user-123',
      'name': 'Jane Doe',
      'email': 'jane@example.com',
    },
  };

  test('AuthResponseModel fromJson deserializes correctly', () {
    final result = AuthResponseModel.fromJson(jsonMap);
    expect(result, equals(model));
    expect(result.accessToken, equals('access-token-xyz'));
    expect(result.refreshToken, equals('refresh-token-xyz'));
    expect(result.user, equals(user));
  });

  test('AuthResponseModel toJson serializes correctly', () {
    final result = model.toJson();
    expect(result, equals(jsonMap));
  });

  test('AuthResponseModel equality works based on props', () {
    const model2 = AuthResponseModel(
      accessToken: 'access-token-xyz',
      refreshToken: 'refresh-token-xyz',
      user: user,
    );
    expect(model, equals(model2));
  });
}
