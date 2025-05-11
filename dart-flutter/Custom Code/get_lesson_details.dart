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

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> getLessonDetails(
    int lessonId, String apiKey, String endpoint) async {
  try {
    final url = Uri.parse(endpoint + '/rest/v1/rpc/get_lesson_details');

    final headers = {
      'Content-Type': 'application/json',
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({'lesson_id': lessonId});

    final response = await http.post(
      url, // Use the already parsed URL
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData; // Return the parsed JSON data
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}
