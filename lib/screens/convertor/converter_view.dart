import 'package:bankwisewithgetx/components/custom_text_field.dart';
import 'package:bankwisewithgetx/screens/convertor/convertor_controller.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrencyConvertorView extends StatelessWidget {
  final ConverterController controller = Get.put(ConverterController());

  CurrencyConvertorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFEFEF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Currency Converter'),
      ),
      body: GetBuilder<ConverterController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Check live rates, set rate alerts, \n receive notifications and more.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          _selectDate(context);
                          controller.update();
                        },
                        child:
                            Text("Selected Date : ${controller.selectedDate}"),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: controller.selectedFromCurrency,
                              onChanged: (value) async {
                                controller.selectedFromCurrency = value!;

                                controller.update();
                                await controller.updateFromCurrencyValue();
                                if (kDebugMode) {
                                  print(controller.selectedToCurrency);
                                }
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CountryFlag.fromCountryCode(
                                          currency == "EUR"
                                              ? "DE"
                                              : currency.substring(0, 2),
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            currency), // Use currency code here
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            child: CustomTextField(
                              onChanged: (p0) {
                                if (num.tryParse(controller.fromCurrAmount.text)
                                    is num) {
                                  controller.calculateCurrtoValue();
                                } else {
                                  Get.snackbar("Error",
                                      "Only numbers are accepted in currency value.");
                                }
                              },
                              controller: controller.fromCurrAmount,
                              hintText: controller.selectedFromCurrencyValue,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      // switch button
                      SizedBox(
                        height: 100,
                        child: InkWell(
                          onTap: () {
                            controller.switchCaseCurrandVal();
                          },
                          child: const Icon(
                            Icons.swap_vertical_circle_sharp,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: controller.selectedToCurrency,
                              onChanged: (value) async {
                                controller.selectedToCurrency = value!;
                                controller.update();
                                await controller.updateToCurrencyValue();
                                if (kDebugMode) {
                                  print(controller.selectedToCurrency);
                                }
                              },
                              items: controller.currencyOptions.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: SizedBox(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CountryFlag.fromCountryCode(
                                          currency == "EUR"
                                              ? "DE"
                                              : currency.substring(0, 2),
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            currency), // Use currency code here
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: CustomTextField(
                              onChanged: (p0) {
                                if (num.tryParse(controller.toCurrAmount.text)
                                    is num) {
                                  controller.calculateCurrFromValue();
                                } else {
                                  Get.snackbar("Error",
                                      "Only numbers are accepted in currency value.");
                                }
                              },
                              controller: controller.toCurrAmount,
                              hintText: controller.selectedToCurrencyValue,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                    "Note: Initial Values of all currencies are against PKR 1"),

                // CustomTextField(
                //   keyboardType: TextInputType.number,
                //   controller: controller.convertingAmountController,
                //   hintText: "Your Amount",
                // ),
                // const SizedBox(height: 20),
                // Text(controller.convertedAmount.toStringAsFixed(4)),
                // const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () async {
                //     // updateValues();
                //     log(controller.convertingAmountController.text);
                //     if (num.tryParse(controller.convertingAmountController.text)
                //         is num) {
                //       if (controller.selectedFromCurrency == "PKR") {
                //         controller.selectedFromCurrencyValue = "1";
                //         controller.update();
                //       } else {
                //         controller.selectedFromCurrencyValue =
                //             await getCurrencyValue(controller.selectedDate,
                //                 controller.selectedFromCurrency);
                //         log(controller.selectedFromCurrencyValue.toString());
                //         controller.update();
                //       }

                //       if (controller.selectedToCurrency == "PKR") {
                //         controller.selectedToCurrencyValue = "1";
                //         controller.update();
                //       } else {
                //         controller.selectedToCurrencyValue =
                //             await getCurrencyValue(controller.selectedDate,
                //                 controller.selectedToCurrency);
                //         controller.update();
                //       }

                //       controller.convertedAmount = getConvertedAmount(
                //         controller.selectedFromCurrencyValue,
                //         controller.selectedToCurrencyValue,
                //         controller.convertingAmountController.text,
                //       );
                //       controller.update();
                //       if (kDebugMode) {
                //         print(controller.convertedAmount.toStringAsFixed(4));
                //       }
                //     } else {
                //       Get.snackbar("Error",
                //           "Only numbers are accepted in currency value.");
                //     }
                //   },
                //   child: const Text("Convert"),
                // ),
              ],
            ),
          ),
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
      await controller.updateFromCurrencyValue();
      await controller.updateToCurrencyValue();
      controller.update();
    }
  }
}
