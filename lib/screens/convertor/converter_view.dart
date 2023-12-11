import 'dart:developer';
import 'package:bankwisewithgetx/components/custom_text_field.dart';
import 'package:bankwisewithgetx/screens/convertor/convertor_controller.dart';
import 'package:bankwisewithgetx/services/converted_amount_function.dart';
import 'package:bankwisewithgetx/services/fetch_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrencyConvertorView extends StatelessWidget {
  final ConverterController controller = Get.put(ConverterController());

  CurrencyConvertorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: GetBuilder<ConverterController>(
        builder: (controller) => Column(
          children: [
            TextButton(
              onPressed: () {
                _selectDate(context);
                controller.update();
              },
              child: Text("Selected Date : ${controller.selectedDate}"),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: controller.selectedFromCurrency,
              onChanged: (value) {
                controller.selectedFromCurrency = value!;

                if (kDebugMode) {
                  print(controller.selectedFromCurrency);
                }
                controller.update();
              },
              items: controller.currencyOptions.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: controller.selectedToCurrency,
              onChanged: (value) {
                controller.selectedToCurrency = value!;
                if (kDebugMode) {
                  print(controller.selectedToCurrency);
                }
                controller.update();
              },
              items: controller.currencyOptions.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              keyboardType: TextInputType.number,
              controller: controller.convertingAmountController,
              hintText: "Your Amount",
            ),
            const SizedBox(height: 20),
            Text(controller.convertedAmount.toStringAsFixed(4)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // updateValues();
                log(controller.convertingAmountController.text);
                if (num.tryParse(controller.convertingAmountController.text)
                    is num) {
                  if (controller.selectedFromCurrency == "PKR") {
                    controller.selectedFromCurrencyValue = "1";
                    controller.update();
                  } else {
                    controller.selectedFromCurrencyValue =
                        await getCurrencyValue(controller.selectedDate,
                            controller.selectedFromCurrency);
                    log(controller.selectedFromCurrencyValue.toString());
                    controller.update();
                  }

                  if (controller.selectedToCurrency == "PKR") {
                    controller.selectedToCurrencyValue = "1";
                    controller.update();
                  } else {
                    controller.selectedToCurrencyValue = await getCurrencyValue(
                        controller.selectedDate, controller.selectedToCurrency);
                    controller.update();
                  }

                  controller.convertedAmount = getConvertedAmount(
                    controller.selectedFromCurrencyValue,
                    controller.selectedToCurrencyValue,
                    controller.convertingAmountController.text,
                  );
                  controller.update();
                  if (kDebugMode) {
                    print(controller.convertedAmount.toStringAsFixed(4));
                  }
                } else {
                  Get.snackbar(
                      "Error", "Only numbers are accepted in currency value.");
                }
              },
              child: const Text("Convert"),
            ),
          ],
        ),
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
      final newSelectedDate = controller.getDateFromValue(dateValue);
      controller.selectedDate = newSelectedDate;
      // Now you have the dateValue, and you can search for it in your date column
      debugPrint('Selected Date: $picked');
      debugPrint('Date Value: $dateValue');
      controller.update();
    }
  }
}
