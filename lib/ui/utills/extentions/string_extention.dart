extension StringExtension on String {
  String get nkStringCapitalizeFirstCaracter {
    if (this.isEmpty) {
    return this;
  }
  return this.length > 0
      ? "${this[0].toUpperCase()}${substring(1)}" 
      : this.toUpperCase();
  }

  String get nkValueWithCurrencySymbol {
    return "\$ $this";
  }
  String get nkValueWithPercentageSymbol {
    return "$this%";
  }
}

String formatAmount(dynamic value) {
  double amount;

  try {
    if (value == null) {
      amount = 0.0;
    } else if (value is String) {
      amount = double.tryParse(value) ?? 0.0; 
    } else if (value is int) {
      amount = value.toDouble(); 
    } else if (value is double) {
      amount = value; 
    } else {
      throw ArgumentError('Unsupported value type: ${value.runtimeType}');
    }
    String formattedAmount = amount.toStringAsFixed(2);
    return '\$ ' + formattedAmount;
  } catch (e) {
    print('Error in formatAmount: $e');
    rethrow;
  }
}


String addCurrencySymbol() {
  return '\$';
}