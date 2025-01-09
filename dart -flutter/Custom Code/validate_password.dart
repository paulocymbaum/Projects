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

bool validatePassword(String password) {
  // No minimum length check

  // Regular expressions for different character types
  bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
  bool hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

  // Check if all character types are present
  return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
}
