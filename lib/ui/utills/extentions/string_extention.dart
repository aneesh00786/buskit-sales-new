import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';

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
    final currencySymbol = SessionHelper.settingsData
          ?.firstWhere(
            (setting) => setting.key == 'currency_symbol',
            orElse: () => AllCompanySettingsData(
              key: 'currency_symbol',
              value: '',
            ),
          )
          .value ??
      '';
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
    return currencySymbol + formattedAmount;
  } catch (e) {
    print('Error in formatAmount: $e');
    rethrow;
  }
}
String getStatusName(int status) {
  switch (status) {
    case 0:
      return 'Pre-Order';
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

String addCurrencySymbol() {
  return '\$';
}