import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<List<String>>?> fetchGoogleSheetData(
    String range, String apiKey, String spreadsheetId) async {
  final response = await http.get(
    Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range?key=$apiKey'),
  );

  if (response.statusCode == 200) {
    // Parse and process the data here.
    final Map<String, dynamic> data = json.decode(response.body);
    final List<List<String>> parsedData = [];

    if (data.containsKey('values')) {
      for (final row in data['values']) {
        final List<String> rowData = List<String>.from(row);
        parsedData.add(rowData);
      }
    }

    return parsedData;
  } else {
    // Handle error.
    return null;
  }
}
