// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> changePassword(String? newPassword) async {
  try {
    final response = await SupaFlow.client.auth
        .updateUser(UserAttributes(password: newPassword));
    return response.user != null
        ? 'Password updated successfully'
        : 'Password update failed';
  } on AuthException catch (error) {
    switch (error.code) {
      case 'same_password':
        return 'New password must be different from the current password';
      case 'weak_password':
        return 'Password is too weak. Please choose a stronger password';
      default:
        return error.message;
    }
  } catch (error) {
    return 'An unexpected error occurred: $error';
  }
}
