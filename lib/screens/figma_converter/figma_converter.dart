import 'dart:developer';
import 'package:bankwisewithgetx/components/custom_text_field.dart';
import 'package:bankwisewithgetx/screens/convertor/convertor_controller.dart';
import 'package:bankwisewithgetx/screens/figma_converter/figma_convert_controller.dart';
import 'package:bankwisewithgetx/services/converted_amount_function.dart';
import 'package:bankwisewithgetx/services/fetch_data.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FigmaCurrencyConvertorView extends StatelessWidget {
  final FigmaConverterController controller =
      Get.put(FigmaConverterController());

  FigmaCurrencyConvertorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Currency Converter'),
      ),
      body: GetBuilder<ConverterController>(
        builder: (controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
                "Check live rates, set rate alerts, receive notifications and more."),
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
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CountryFlag.fromCountryCode(
                          currency == "EUR" ? "DE" : currency.substring(0, 2),
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(currency), // Use currency code here
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            // DropdownButton<String>(
            //   value: controller.selectedFromCurrency,
            //   onChanged: (value) {
            //     controller.selectedFromCurrency = value!;

            //     if (kDebugMode) {
            //       print(controller.selectedFromCurrency);
            //     }
            //     controller.update();
            //   },
            //   items: controller.currencyOptions.map((currency) {
            //     return DropdownMenuItem(
            //       value: currency,
            //       child: Text(currency),
            //     );
            //   }).toList(),
            // ),
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
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CountryFlag.fromCountryCode(
                          currency == "EUR" ? "DE" : currency.substring(0, 2),
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(currency), // Use currency code here
                      ],
                    ),
                  ),
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
