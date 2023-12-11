import 'package:bankwisewithgetx/screens/convertor/converter_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Bank Wise Exchange Rate Calculator",
      home: CurrencyConvertorView(),
      themeMode: ThemeMode.dark,
    );
  }
}
