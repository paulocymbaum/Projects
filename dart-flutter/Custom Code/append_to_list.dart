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

List<String> appendToList(List<String> list, String stringToAppend) {
  // Create a new list to avoid modifying the original
  List<String> appendedList = [];

  // Loop through the original list and add each item
  for (String item in list) {
    appendedList.add(item);
  }

  // Append the new string
  appendedList.add(stringToAppend);

  return appendedList;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
