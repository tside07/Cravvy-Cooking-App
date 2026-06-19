import 'package:cravvy_cooking_app/data/services/account_deletion_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountDeletionService response parsing', () {
    test('isDeleteAccountSuccess accepts success payload', () {
      expect(
        AccountDeletionService.isDeleteAccountSuccess({'success': true}),
        isTrue,
      );
    });

    test('isDeleteAccountSuccess rejects missing or false success', () {
      expect(AccountDeletionService.isDeleteAccountSuccess(null), isFalse);
      expect(
        AccountDeletionService.isDeleteAccountSuccess({'success': false}),
        isFalse,
      );
      expect(
        AccountDeletionService.isDeleteAccountSuccess({'error': 'fail'}),
        isFalse,
      );
    });

    test('deleteAccountErrorMessage extracts error string', () {
      expect(
        AccountDeletionService.deleteAccountErrorMessage({
          'error': 'Unauthorized',
        }),
        'Unauthorized',
      );
      expect(AccountDeletionService.deleteAccountErrorMessage({}), isNull);
    });
  });
}
