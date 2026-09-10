import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewState', () {
    test('IdleState equality works', () {
      expect(const IdleState(), equals(const IdleState()));
    });

    test('LoadingState equality works', () {
      expect(const LoadingState(), equals(const LoadingState()));
    });

    test('SuccessState equality works with data', () {
      expect(const SuccessState<String>('data'), equals(const SuccessState<String>('data')));
      expect(const SuccessState<String>('data1'), isNot(equals(const SuccessState<String>('data2'))));
    });

    test('ErrorState equality works with message', () {
      expect(const ErrorState('error'), equals(const ErrorState('error')));
    });
  });
}
