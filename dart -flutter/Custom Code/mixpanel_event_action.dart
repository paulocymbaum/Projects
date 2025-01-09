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

import 'dart:io'; // Import dart:io for fetch function
import 'dart:convert'; // Import dart:convert for utf8

Future<String> mixpanelEventAction(
  String eventName,
  String userId,
  DateTime eventTime,
  String eventIdentifier,
  String device,
  String plan,
  String button,
  String userType,
) async {
  try {
    final response = await HttpClient().postUrl(
      Uri.parse(
          'https://your-supabase-url.supabase.co/functions/v1/mixpanel-event'),
    );
    response.headers.set('Content-Type', 'application/json');
    response.add(utf8.encode(
      jsonEncode({
        'event': eventName,
        'properties': {
          'time': eventTime.millisecondsSinceEpoch ~/ 1000, // Unix timestamp
          'distinct_id': userId,
          'insert_id':
              eventIdentifier, // Use 'insert_id' instead of '$insert_id'
          'device': device,
          'plan': plan,
          'button': button,
          'user_type': userType,
        },
      }),
    ));
    final httpResponse = await response.close();
    if (httpResponse.statusCode == 200) {
      // Event sent successfully
      return 'Event sent successfully';
    } else {
      // Error sending event
      final errorMessage = await httpResponse.transform(utf8.decoder).join();
      return 'Error sending event: ${errorMessage}';
    }
  } catch (error) {
    return 'Error: ${error.toString()}';
  }
}
