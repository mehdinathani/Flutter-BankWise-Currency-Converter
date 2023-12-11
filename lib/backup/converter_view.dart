import 'dart:developer';

import 'package:bankwisewithgetx/components/custom_text_field.dart';
import 'package:bankwisewithgetx/configuration/config.dart';
import 'package:bankwisewithgetx/services/converted_amount_function.dart';
import 'package:bankwisewithgetx/services/fetch_data.dart';
import 'package:bankwisewithgetx/services/google_sheets_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:core';
import 'package:intl/intl.dart';

class CurrencyConvertor extends StatefulWidget {
  const CurrencyConvertor({super.key});

  @override
  State<CurrencyConvertor> createState() => _CurrencyConvertorState();
}

class _CurrencyConvertorState extends State<CurrencyConvertor> {
  String selectedDate = '';
  String selectedFromCurrency = '';
  String selectedToCurrency = '';
  List<String> dateOptions = [];
  List<String> currencyOptions = [];
  String selectedFromCurrencyValue = "";
  String selectedToCurrencyValue = "";
  final TextEditingController _convertingAmount = TextEditingController();
  num convertedAmount = 0;

  final apiKey = GoogleApiConfig.apiKey;
  final spreadsheetId = GoogleApiConfig.SpreadsheetID;
  List<List<String>>? sheetData;
  late Future<List<List<String>>?> fetchDataFuture;
  final customSizedBox = const SizedBox(height: 20);

  @override
  void initState() {
    super.initState();
    fetchDateOptions();
    fetchCurrencyOptions();
    fetchDataFuture = fetchData();
  }

  Future<void> fetchDateOptions() async {
    const range = 'A7:A';
    final data = await fetchGoogleSheetData(range, apiKey, spreadsheetId);
    if (data != null && data.isNotEmpty) {
      dateOptions = data.map((row) => row[0]).toList();
      if (dateOptions.isNotEmpty) {
        selectedDate = dateOptions.last;
      }
      setState(() {});
    }
  }

  Future<void> fetchCurrencyOptions() async {
    const range = '6:6';
    final data = await fetchGoogleSheetData(range, apiKey, spreadsheetId);
    if (data != null && data.isNotEmpty && data[0].isNotEmpty) {
      currencyOptions = data[0].sublist(1);
      currencyOptions.add("PKR");
      if (currencyOptions.isNotEmpty) {
        selectedFromCurrency = currencyOptions[0];
        selectedToCurrency = currencyOptions[0];
      }
      setState(() {});
    }
  }

  void updateValues() async {
    if (selectedFromCurrency == "PKR") {
      selectedFromCurrencyValue = "1";
    } else {
      selectedFromCurrencyValue =
          await getCurrencyValue(selectedDate, selectedFromCurrency);
      debugPrint(selectedFromCurrencyValue.toString());
    }

    if (selectedToCurrency == "PKR") {
      selectedToCurrencyValue = "1";
    } else {
      selectedToCurrencyValue =
          await getCurrencyValue(selectedDate, selectedToCurrency);
    }
  }

  String getDateFromValue(int dateValue) {
    final formatter = DateFormat('dd-MMM-yyyy');

    String? closestDate;

    for (final date in dateOptions) {
      final dateTime = formatter.parse(date);
      final dateValueInList = dateTime.millisecondsSinceEpoch;

      if (dateValue == dateValueInList) {
        log("DateValue: $dateValue = Date: $date matched.");
        return date;
      } else if (dateValueInList < dateValue) {
        if (closestDate == null ||
            dateValue - dateValueInList <
                dateValue -
                    formatter.parse(closestDate).millisecondsSinceEpoch) {
          closestDate = date;
        }
      }
    }

    // If the user-selected date is earlier than the minimum date in your list,
    // return the minimum date as the closest date.
    if (closestDate == null && dateOptions.isNotEmpty) {
      closestDate = dateOptions.first;
    }

    if (closestDate != null) {
      log("Closest Date: $closestDate");
      return closestDate;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text("Selected Date : $selectedDate"),
          ),

          customSizedBox,
          DropdownButton<String>(
            value: selectedFromCurrency,
            onChanged: (value) {
              setState(() {
                selectedFromCurrency = value!;
                if (kDebugMode) {
                  print(selectedFromCurrency);
                }
              });
            },
            items: currencyOptions.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
          ),
          customSizedBox,
          DropdownButton<String>(
            value: selectedToCurrency,
            onChanged: (value) {
              setState(() {
                selectedToCurrency = value!;
                if (kDebugMode) {
                  print(selectedToCurrency);
                }
              });
            },
            items: currencyOptions.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
          ),
          customSizedBox,
          CustomTextField(
            keyboardType: TextInputType.number,
            controller: _convertingAmount,
            hintText: "Your Amount",
          ),
          customSizedBox,
          Text(convertedAmount.toStringAsFixed(4)),
          customSizedBox,

          //elevated button
          ElevatedButton(
            onPressed: () async {
              // updateValues();
// again for debug
              log(_convertingAmount.text);
              if (num.tryParse(_convertingAmount.text) is num) {
                if (selectedFromCurrency == "PKR") {
                  selectedFromCurrencyValue = "1";
                } else {
                  selectedFromCurrencyValue = await getCurrencyValue(
                      selectedDate, selectedFromCurrency);
                  log(selectedFromCurrencyValue.toString());
                }

                if (selectedToCurrency == "PKR") {
                  selectedToCurrencyValue = "1";
                } else {
                  selectedToCurrencyValue =
                      await getCurrencyValue(selectedDate, selectedToCurrency);
                }
// above again for debugg
                convertedAmount = getConvertedAmount(
                  selectedFromCurrencyValue,
                  selectedToCurrencyValue,
                  _convertingAmount.text,
                );
                if (kDebugMode) {
                  print(convertedAmount.toStringAsFixed(4));
                }
                setState(() {});
              } else {
                Get.snackbar(
                    "Error", "Only numbers are accepted in currency value.");
              }
            },
            child: const Text("Convert"),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final dateValue = picked.millisecondsSinceEpoch;
      final newSelectedDate = getDateFromValue(dateValue);
      setState(() {
        selectedDate = newSelectedDate;
      });

      // Now you have the dateValue, and you can search for it in your date column
      debugPrint('Selected Date: $picked');
      debugPrint('Date Value: $dateValue');

      // Perform the search in your date column
      // For example, call a method like searchByDateValue(dateValue);
      // searchByDateValue(dateValue);
    }
  }
}
