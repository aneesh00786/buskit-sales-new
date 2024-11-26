extension StringExtension on String {
  String get nkStringCapitalizeFirstCaracter {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get nkValueWithCurrencySymbol {
    return "\$ $this";
  }
  String get nkValueWithPercentageSymbol {
    return "$this%";
  }
}

String formatAmount(dynamic value) {
  // Convert the dynamic value to double
  double amount;

  if (value is String) {
    amount = double.tryParse(value) ?? 0.0;
  } else if (value is int) {
    amount = value.toDouble();
  } else if (value is double) {
    amount = value;
  } else {
    throw ArgumentError('Unsupported value type');
  }

  // Format the amount to two decimal places
  String formattedAmount = amount.toStringAsFixed(2);

  // Return with the $ symbol
  return '\$ ' + formattedAmount;
}

String addCurrencySymbol() {
  return '\$';
}