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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> insertLessonData(
    dynamic jsonData, String apiKey, String endpoint) async {
  // No UUID validation needed here
  try {
    // Define the Supabase endpoint
    final url = Uri.parse(endpoint + '/rest/v1/rpc/insert_lesson_data');

    // Correctly format the JSON data for the request body
    final body = jsonEncode({
      'json_data': {
        // Top-level key 'json_data'
        'lesson': jsonData // Your lesson data
      }
    });

    // Make the POST request to the Supabase function
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    // Check the response status
    if (response.statusCode == 200) {
      return 'Lesson data inserted successfully!';
    } else {
      return 'Error inserting lesson data: ${response.statusCode} - ${response.body}';
    }
  } catch (e) {
    return 'An error occurred: $e';
  }
}
