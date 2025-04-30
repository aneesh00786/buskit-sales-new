import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyUtils {
  static final Map<String, Map<String, String>> countryCurrencyMap = {
    "AFG": {"name": "Afghanistan", "code": "AFN", "symbol": "؋"},
    "ALB": {"name": "Albania", "code": "ALL", "symbol": "L"},
    "DZA": {"name": "Algeria", "code": "DZD", "symbol": "د.ج"},
    "AND": {"name": "Andorra", "code": "EUR", "symbol": "€"},
    "AGO": {"name": "Angola", "code": "AOA", "symbol": "Kz"},
    "ARG": {"name": "Argentina", "code": "ARS", "symbol": "\$"},
    "ARM": {"name": "Armenia", "code": "AMD", "symbol": "֏"},
    "AUS": {"name": "Australia", "code": "AUD", "symbol": "\$"},
    "AUT": {"name": "Austria", "code": "EUR", "symbol": "€"},
    "AZE": {"name": "Azerbaijan", "code": "AZN", "symbol": "₼"},
    "BHR": {"name": "Bahrain", "code": "BHD", "symbol": ".د.ب"},
    "BGD": {"name": "Bangladesh", "code": "BDT", "symbol": "৳"},
    "BLR": {"name": "Belarus", "code": "BYN", "symbol": "Br"},
    "BEL": {"name": "Belgium", "code": "EUR", "symbol": "€"},
    "BRA": {"name": "Brazil", "code": "BRL", "symbol": "R\$"},
    "CAN": {"name": "Canada", "code": "CAD", "symbol": "\$"},
    "CHN": {"name": "China", "code": "CNY", "symbol": "¥"},
    "COL": {"name": "Colombia", "code": "COP", "symbol": "\$"},
    "HRV": {"name": "Croatia", "code": "HRK", "symbol": "kn"},
    "CYP": {"name": "Cyprus", "code": "EUR", "symbol": "€"},
    "CZE": {"name": "Czech Republic", "code": "CZK", "symbol": "Kč"},
    "DNK": {"name": "Denmark", "code": "DKK", "symbol": "kr"},
    "EGY": {"name": "Egypt", "code": "EGP", "symbol": "£"},
    "EST": {"name": "Estonia", "code": "EUR", "symbol": "€"},
    "FIN": {"name": "Finland", "code": "EUR", "symbol": "€"},
    "FRA": {"name": "France", "code": "EUR", "symbol": "€"},
    "DEU": {"name": "Germany", "code": "EUR", "symbol": "€"},
    "GRC": {"name": "Greece", "code": "EUR", "symbol": "€"},
    "HKG": {"name": "Hong Kong", "code": "HKD", "symbol": "\$"},
    "HUN": {"name": "Hungary", "code": "HUF", "symbol": "Ft"},
    "ISL": {"name": "Iceland", "code": "ISK", "symbol": "kr"},
    "IND": {"name": "India", "code": "INR", "symbol": "₹"},
    "IDN": {"name": "Indonesia", "code": "IDR", "symbol": "Rp"},
    "IRN": {"name": "Iran", "code": "IRR", "symbol": "﷼"},
    "IRL": {"name": "Ireland", "code": "EUR", "symbol": "€"},
    "ISR": {"name": "Israel", "code": "ILS", "symbol": "₪"},
    "ITA": {"name": "Italy", "code": "EUR", "symbol": "€"},
    "JPN": {"name": "Japan", "code": "JPY", "symbol": "¥"},
    "JOR": {"name": "Jordan", "code": "JOD", "symbol": "د.ا"},
    "KAZ": {"name": "Kazakhstan", "code": "KZT", "symbol": "₸"},
    "KEN": {"name": "Kenya", "code": "KES", "symbol": "Sh"},
    "KOR": {"name": "South Korea", "code": "KRW", "symbol": "₩"},
    "KWT": {"name": "Kuwait", "code": "KWD", "symbol": "د.ك"},
    "LVA": {"name": "Latvia", "code": "EUR", "symbol": "€"},
    "LBN": {"name": "Lebanon", "code": "LBP", "symbol": "ل.ل"},
    "LTU": {"name": "Lithuania", "code": "EUR", "symbol": "€"},
    "LUX": {"name": "Luxembourg", "code": "EUR", "symbol": "€"},
    "MYS": {"name": "Malaysia", "code": "MYR", "symbol": "RM"},
    "MEX": {"name": "Mexico", "code": "MXN", "symbol": "\$"},
    "NLD": {"name": "Netherlands", "code": "EUR", "symbol": "€"},
    "NZL": {"name": "New Zealand", "code": "NZD", "symbol": "\$"},
    "NGA": {"name": "Nigeria", "code": "NGN", "symbol": "₦"},
    "NOR": {"name": "Norway", "code": "NOK", "symbol": "kr"},
    "OMN": {"name": "Oman", "code": "OMR", "symbol": "ر.ع."},
    "PAK": {"name": "Pakistan", "code": "PKR", "symbol": "₨"},
    "PHL": {"name": "Philippines", "code": "PHP", "symbol": "₱"},
    "POL": {"name": "Poland", "code": "PLN", "symbol": "zł"},
    "PRT": {"name": "Portugal", "code": "EUR", "symbol": "€"},
    "QAT": {"name": "Qatar", "code": "QAR", "symbol": "ر.ق"},
    "ROU": {"name": "Romania", "code": "RON", "symbol": "lei"},
    "RUS": {"name": "Russia", "code": "RUB", "symbol": "₽"},
    "SAU": {"name": "Saudi Arabia", "code": "SAR", "symbol": "﷼"},
    "SGP": {"name": "Singapore", "code": "SGD", "symbol": "\$"},
    "ZAF": {"name": "South Africa", "code": "ZAR", "symbol": "R"},
    "ESP": {"name": "Spain", "code": "EUR", "symbol": "€"},
    "SWE": {"name": "Sweden", "code": "SEK", "symbol": "kr"},
    "CHE": {"name": "Switzerland", "code": "CHF", "symbol": "Fr."},
    "THA": {"name": "Thailand", "code": "THB", "symbol": "฿"},
    "TUR": {"name": "Turkey", "code": "TRY", "symbol": "₺"},
    "ARE": {"name": "United Arab Emirates", "code": "AED", "symbol": "د.إ"},
    "GBR": {"name": "United Kingdom", "code": "GBP", "symbol": "£"},
    "USA": {"name": "United States", "code": "USD", "symbol": "\$"},
    "VNM": {"name": "Vietnam", "code": "VND", "symbol": "₫"}
  };

  static Map<String, String>? findCurrency(String query) {
    query = query.toUpperCase();

    if (countryCurrencyMap.containsKey(query)) {
      return countryCurrencyMap[query];
    }

    for (final entry in countryCurrencyMap.entries) {
      if (entry.value["name"]?.toUpperCase() == query) {
        return {"code": entry.key, ...entry.value};
      }
    }

    return {"name": "Unknown", "code": "N/A", "symbol": "N/A"};
  }

  static Future<Map<String, dynamic>> convertToLocalCurrency({
    required double amount,
    String fromCurrency = "USD",
    List<dynamic>? listOfSavedData,
  }) async {
    if (listOfSavedData == null || listOfSavedData.isEmpty) {
      print("listOfSavedData is empty, using default country (USA)");
      return {"symbol": "\$", "price": amount};
    }
    final userCountryCode = listOfSavedData[0]["country"];
    final userCurrency = findCurrency(userCountryCode);

    if (userCurrency == null || userCurrency["code"] == "N/A") {
      print("User currency not found, using default USD.");
      return {"symbol": "\$", "price": amount};
    }
    final toCurrency = userCurrency["code"];

    try {
      final response = await http.get(Uri.parse(
          "https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency"));
      final data = json.decode(response.body);
      if (data["rates"] == null || !data["rates"].containsKey(toCurrency)) {
        print("Exchange rate for $toCurrency not found.");
        return {"symbol": userCurrency["symbol"], "price": amount};
      }
      final convertedPrice = double.parse(data["rates"][toCurrency].toString())
          .toStringAsFixed(2);
      return {"symbol": userCurrency["symbol"], "price": convertedPrice};
    } catch (error) {
      print("Currency conversion failed: $error");
      return {"symbol": "\$", "price": amount};
    }
  }
}
