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