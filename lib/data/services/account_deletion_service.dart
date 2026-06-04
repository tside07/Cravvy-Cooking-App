import 'package:cravvy_cooking_app/data/services/supabase_service.dart';
import 'package:flutter/foundation.dart';

/// Typed failure when `delete-account` Edge Function fails.
class AccountDeletionException implements Exception {
  AccountDeletionException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AccountDeletionException($statusCode): $message';
}

/// Invokes Supabase Edge Function `delete-account`.
class AccountDeletionService {
  static const functionName = 'delete-account';
  static const _timeout = Duration(seconds: 30);

  static Future<void> deleteAccount() async {
    final response = await SupabaseService.client.functions
        .invoke(functionName, body: <String, dynamic>{})
        .timeout(_timeout);

    final data = response.data;
    if (isDeleteAccountSuccess(data)) return;

    final err = deleteAccountErrorMessage(data) ??
        'Không thể xóa tài khoản (${response.status}).';
    throw AccountDeletionException(err, statusCode: response.status);
  }

  @visibleForTesting
  static bool isDeleteAccountSuccess(dynamic data) {
    return data is Map && data['success'] == true;
  }

  @visibleForTesting
  static String? deleteAccountErrorMessage(dynamic data) {
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return null;
  }
}
