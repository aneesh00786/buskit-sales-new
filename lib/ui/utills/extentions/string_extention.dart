import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String get nkStringCapitalizeFirstCaracter {
    if (this.isEmpty) {
      return this; 
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get nkStringCleanAndCapitalize {
    if (isEmpty) return this;

    String cleaned = replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ');

    List<String> words = cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .toList();

    return words.join(' ');
  }

  String get nkValueWithCurrencySymbol {
    final currencySymbol = (SessionHelper.settingsData
                ?.firstWhere(
                  (setting) => setting.key == 'currency_symbol',
                  orElse: () => AllCompanySettingsData(
                    key: 'currency_symbol',
                    value: '',
                  ),
                )
                .value ??
            '')
        .trim();
    return "$currencySymbol $this";
  }

  String get nkValueWithPercentageSymbol {
    return "$this %";
  }
}

String formatAmount(dynamic value) {
  final currencySymbol = (SessionHelper.settingsData
              ?.firstWhere(
                (setting) => setting.key == 'currency_symbol',
                orElse: () => AllCompanySettingsData(
                  key: 'currency_symbol',
                  value: '',
                ),
              )
              .value ??
          '')
      .trim();
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

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 2,
    );

    String formattedAmount = formatter.format(amount);
    return "$currencySymbol\u00A0$formattedAmount";
  } catch (e) {
    rethrow;
  }
}

String formatAmountOnly(dynamic value) {
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

  final formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_IN',
    decimalDigits: 2,
  );

  return formatter.format(amount);
}

String addCurrencySymbol() {
  final currencySymbol = (SessionHelper.settingsData
              ?.firstWhere(
                (setting) => setting.key == 'currency_symbol',
                orElse: () => AllCompanySettingsData(
                  key: 'currency_symbol',
                  value: '',
                ),
              )
              .value ??
          '')
      .trim();
  return currencySymbol;
}

String getStatusName(int status) {
  switch (status) {
    case 0:
      return 'Booking';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    case 3:
      return 'Cancelled';
    case 4:
      return 'Draft';
    case 5:
      return 'Processing';
    case 6:
      return 'Pending';
    case 7:
      return 'Estimate';
    case 10:
      return 'Packed for Delivery';
    case 11:
      return 'New Order';
    case 12:
      return 'Waiting for Approval';
    case 13:
      return 'Rejected';
    case 14:
      return 'Quick Sale';
    default:
      return 'Unknown';
  }
}
