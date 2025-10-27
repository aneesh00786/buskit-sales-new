import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyUtils {
  static final Map<String, Map<String, String>> countryCurrencyMap = {
  "AFG": {"name": "Afghanistan", "code": "AFN", "symbol": "؋", "phoneCode": "+93"},
  "ALB": {"name": "Albania", "code": "ALL", "symbol": "L", "phoneCode": "+355"},
  "DZA": {"name": "Algeria", "code": "DZD", "symbol": "د.ج", "phoneCode": "+213"},
  "AND": {"name": "Andorra", "code": "EUR", "symbol": "€", "phoneCode": "+376"},
  "AGO": {"name": "Angola", "code": "AOA", "symbol": "Kz", "phoneCode": "+244"},
  "ARG": {"name": "Argentina", "code": "ARS", "symbol": "\$", "phoneCode": "+54"},
  "ARM": {"name": "Armenia", "code": "AMD", "symbol": "֏", "phoneCode": "+374"},
  "AUS": {"name": "Australia", "code": "AUD", "symbol": "\$", "phoneCode": "+61"},
  "AUT": {"name": "Austria", "code": "EUR", "symbol": "€", "phoneCode": "+43"},
  "AZE": {"name": "Azerbaijan", "code": "AZN", "symbol": "₼", "phoneCode": "+994"},
  "BHR": {"name": "Bahrain", "code": "BHD", "symbol": ".د.ب", "phoneCode": "+973"},
  "BGD": {"name": "Bangladesh", "code": "BDT", "symbol": "৳", "phoneCode": "+880"},
  "BLR": {"name": "Belarus", "code": "BYN", "symbol": "Br", "phoneCode": "+375"},
  "BEL": {"name": "Belgium", "code": "EUR", "symbol": "€", "phoneCode": "+32"},
  "BRA": {"name": "Brazil", "code": "BRL", "symbol": "R\$", "phoneCode": "+55"},
  "CAN": {"name": "Canada", "code": "CAD", "symbol": "\$", "phoneCode": "+1"},
  "CHN": {"name": "China", "code": "CNY", "symbol": "¥", "phoneCode": "+86"},
  "COL": {"name": "Colombia", "code": "COP", "symbol": "\$", "phoneCode": "+57"},
  "HRV": {"name": "Croatia", "code": "HRK", "symbol": "kn", "phoneCode": "+385"},
  "CYP": {"name": "Cyprus", "code": "EUR", "symbol": "€", "phoneCode": "+357"},
  "CZE": {"name": "Czech Republic", "code": "CZK", "symbol": "Kč", "phoneCode": "+420"},
  "DNK": {"name": "Denmark", "code": "DKK", "symbol": "kr", "phoneCode": "+45"},
  "EGY": {"name": "Egypt", "code": "EGP", "symbol": "£", "phoneCode": "+20"},
  "EST": {"name": "Estonia", "code": "EUR", "symbol": "€", "phoneCode": "+372"},
  "FIN": {"name": "Finland", "code": "EUR", "symbol": "€", "phoneCode": "+358"},
  "FRA": {"name": "France", "code": "EUR", "symbol": "€", "phoneCode": "+33"},
  "DEU": {"name": "Germany", "code": "EUR", "symbol": "€", "phoneCode": "+49"},
  "GRC": {"name": "Greece", "code": "EUR", "symbol": "€", "phoneCode": "+30"},
  "HKG": {"name": "Hong Kong", "code": "HKD", "symbol": "\$", "phoneCode": "+852"},
  "HUN": {"name": "Hungary", "code": "HUF", "symbol": "Ft", "phoneCode": "+36"},
  "ISL": {"name": "Iceland", "code": "ISK", "symbol": "kr", "phoneCode": "+354"},
  "IND": {"name": "India", "code": "INR", "symbol": "₹", "phoneCode": "+91"},
  "IDN": {"name": "Indonesia", "code": "IDR", "symbol": "Rp", "phoneCode": "+62"},
  "IRN": {"name": "Iran", "code": "IRR", "symbol": "﷼", "phoneCode": "+98"},
  "IRL": {"name": "Ireland", "code": "EUR", "symbol": "€", "phoneCode": "+353"},
  "ISR": {"name": "Israel", "code": "ILS", "symbol": "₪", "phoneCode": "+972"},
  "ITA": {"name": "Italy", "code": "EUR", "symbol": "€", "phoneCode": "+39"},
  "JPN": {"name": "Japan", "code": "JPY", "symbol": "¥", "phoneCode": "+81"},
  "JOR": {"name": "Jordan", "code": "JOD", "symbol": "د.ا", "phoneCode": "+962"},
  "KAZ": {"name": "Kazakhstan", "code": "KZT", "symbol": "₸", "phoneCode": "+7"},
  "KEN": {"name": "Kenya", "code": "KES", "symbol": "Sh", "phoneCode": "+254"},
  "KOR": {"name": "South Korea", "code": "KRW", "symbol": "₩", "phoneCode": "+82"},
  "KWT": {"name": "Kuwait", "code": "KWD", "symbol": "د.ك", "phoneCode": "+965"},
  "LVA": {"name": "Latvia", "code": "EUR", "symbol": "€", "phoneCode": "+371"},
  "LBN": {"name": "Lebanon", "code": "LBP", "symbol": "ل.ل", "phoneCode": "+961"},
  "LTU": {"name": "Lithuania", "code": "EUR", "symbol": "€", "phoneCode": "+370"},
  "LUX": {"name": "Luxembourg", "code": "EUR", "symbol": "€", "phoneCode": "+352"},
  "MYS": {"name": "Malaysia", "code": "MYR", "symbol": "RM", "phoneCode": "+60"},
  "MEX": {"name": "Mexico", "code": "MXN", "symbol": "\$", "phoneCode": "+52"},
  "NLD": {"name": "Netherlands", "code": "EUR", "symbol": "€", "phoneCode": "+31"},
  "NZL": {"name": "New Zealand", "code": "NZD", "symbol": "\$", "phoneCode": "+64"},
  "NGA": {"name": "Nigeria", "code": "NGN", "symbol": "₦", "phoneCode": "+234"},
  "NOR": {"name": "Norway", "code": "NOK", "symbol": "kr", "phoneCode": "+47"},
  "OMN": {"name": "Oman", "code": "OMR", "symbol": "ر.ع.", "phoneCode": "+968"},
  "PAK": {"name": "Pakistan", "code": "PKR", "symbol": "₨", "phoneCode": "+92"},
  "PHL": {"name": "Philippines", "code": "PHP", "symbol": "₱", "phoneCode": "+63"},
  "POL": {"name": "Poland", "code": "PLN", "symbol": "zł", "phoneCode": "+48"},
  "PRT": {"name": "Portugal", "code": "EUR", "symbol": "€", "phoneCode": "+351"},
  "QAT": {"name": "Qatar", "code": "QAR", "symbol": "ر.ق", "phoneCode": "+974"},
  "ROU": {"name": "Romania", "code": "RON", "symbol": "lei", "phoneCode": "+40"},
  "RUS": {"name": "Russia", "code": "RUB", "symbol": "₽", "phoneCode": "+7"},
  "SAU": {"name": "Saudi Arabia", "code": "SAR", "symbol": "﷼", "phoneCode": "+966"},
  "SGP": {"name": "Singapore", "code": "SGD", "symbol": "\$", "phoneCode": "+65"},
  "ZAF": {"name": "South Africa", "code": "ZAR", "symbol": "R", "phoneCode": "+27"},
  "ESP": {"name": "Spain", "code": "EUR", "symbol": "€", "phoneCode": "+34"},
  "SWE": {"name": "Sweden", "code": "SEK", "symbol": "kr", "phoneCode": "+46"},
  "CHE": {"name": "Switzerland", "code": "CHF", "symbol": "Fr.", "phoneCode": "+41"},
  "THA": {"name": "Thailand", "code": "THB", "symbol": "฿", "phoneCode": "+66"},
  "TUR": {"name": "Turkey", "code": "TRY", "symbol": "₺", "phoneCode": "+90"},
  "ARE": {"name": "United Arab Emirates", "code": "AED", "symbol": "د.إ", "phoneCode": "+971"},
  "GBR": {"name": "United Kingdom", "code": "GBP", "symbol": "£", "phoneCode": "+44"},
  "USA": {"name": "United States", "code": "USD", "symbol": "\$", "phoneCode": "+1"},
  "VNM": {"name": "Vietnam", "code": "VND", "symbol": "₫", "phoneCode": "+84"}
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
      return {"symbol": "\$", "price": amount};
    }
    final userCountryCode = listOfSavedData[0]["country"];
    final userCurrency = findCurrency(userCountryCode);

    if (userCurrency == null || userCurrency["code"] == "N/A") {
      return {"symbol": "\$", "price": amount};
    }
    final toCurrency = userCurrency["code"];

    try {
      final response = await http.get(Uri.parse(
          "https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency"));
      final data = json.decode(response.body);
      if (data["rates"] == null || !data["rates"].containsKey(toCurrency)) {
        return {"symbol": userCurrency["symbol"], "price": amount};
      }
      final convertedPrice = double.parse(data["rates"][toCurrency].toString())
          .toStringAsFixed(2);
      return {"symbol": userCurrency["symbol"], "price": convertedPrice};
    } catch (error) {
      return {"symbol": "\$", "price": amount};
    }
  }
}
