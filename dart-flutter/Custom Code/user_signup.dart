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

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> userSignup(
  String email,
  String password,
  String name,
  String? surname,
  String usertype,
  String? teacherid,
  String? photourl,
  String endpoint,
  String apikey,
) async {
  String log = 'Custom action userSignup started\n';
  final url = Uri.parse(endpoint + '/functions/v1/createUser');

  try {
    log += 'Sending request to $url\n';
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apikey',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstname': name,
        'surname': surname ?? '',
        'photo_url': photourl ?? '',
        'user_type': usertype,
        'teacher_id': teacherid ?? '',
      }),
    );

    log += 'Received response with status code: ${response.statusCode}\n';
    log += 'Response body: ${response.body}\n';

    if (response.statusCode == 200) {
      // Handle success
      log += 'User created successfully\n';
      return log + jsonEncode(jsonDecode(response.body));
    } else {
      // Handle error
      log += 'Failed to create user on the API Call: ${response.body}\n';
      return log + 'Error: Failed to create user on the API Call';
    }
  } catch (e) {
    log += 'Error on Dart Function: $e\n';
    return log + 'Error on Dart Function: $e';
  }
}
