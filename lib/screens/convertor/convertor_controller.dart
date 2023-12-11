import 'dart:developer';
import 'package:bankwisewithgetx/configuration/config.dart';
import 'package:bankwisewithgetx/services/fetch_data.dart';
import 'package:bankwisewithgetx/services/google_sheets_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConverterController extends GetxController {
  String selectedDate = '';
  String selectedFromCurrency = '';
  String selectedToCurrency = '';
  List<String> dateOptions = [];
  List<String> currencyOptions = [];
  String selectedFromCurrencyValue = "";
  String selectedToCurrencyValue = "";
  final TextEditingController convertingAmountController =
      TextEditingController();
  num convertedAmount = 0;

  final apiKey = GoogleApiConfig.apiKey;
  final spreadsheetId = GoogleApiConfig.SpreadsheetID;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDateOptions();
    fetchCurrencyOptions();
    fetchDataFuture = fetchData();
  }

  Future<void> fetchDateOptions() async {
    const range = 'A7:A';
    isLoading(true);
    final data = await fetchGoogleSheetData(range, apiKey, spreadsheetId);
    isLoading(false);
    if (data != null && data.isNotEmpty) {
      dateOptions = data.map((row) => row[0]).toList();
      if (dateOptions.isNotEmpty) {
        selectedDate = dateOptions.last;
      }
      update();
    }
  }

  Future<void> fetchCurrencyOptions() async {
    const range = '6:6';
    isLoading(true);
    final data = await fetchGoogleSheetData(range, apiKey, spreadsheetId);
    isLoading(false);
    if (data != null && data.isNotEmpty && data[0].isNotEmpty) {
      currencyOptions = data[0].sublist(1);
      currencyOptions.add("PKR");
      if (currencyOptions.isNotEmpty) {
        selectedFromCurrency = currencyOptions[0];
        selectedToCurrency = currencyOptions[0];
      }
      update();
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
}
