num getConvertedAmount(
  String fromCurrVal,
  String toCurrVal,
  String convAmt,
) {
  num convertedAmount =
      (num.parse(fromCurrVal) / num.parse(toCurrVal) * num.parse(convAmt));

  return convertedAmount;
}
