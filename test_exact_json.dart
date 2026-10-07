import 'dart:convert';

void main() {
  String rawResponse = '[[[["places/ChIJ6eGAduD0k2sRBgoxPd2Ay1k","ChIJ6eGAduD0k2sRBgoxPd2Ay1k",["1 Ziviani Road, Wamuran QLD, Australia",[[null,1]]],[["1 Ziviani Road",[[null,1]]],["Wamuran QLD, Australia"]],["street_address","geocode"]]],[["places/ChIJL9jI4osd1moRVGTtT4KEhT4","ChIJL9jI4osd1moRVGTtT4KEhT4",["Costco Wholesale (under development, 130 Greenhills Road, Pakenham VIC, Australia",[[37,38]]],[["130 Greenhills Road",[[null,1]]],["Costco Wholesale (under development, Pakenham VIC, Australia"]],["geocode","street_address"]]],[["places/ChIJw8Cd0ydE1moRdVihE20aZpc","ChIJw8Cd0ydE1moRdVihE20aZpc",["190 Banksia Street, Bellfield VIC, Australia",[[null,1]]],[["190 Banksia Street",[[null,1]]],["Bellfield VIC, Australia"]],["geocode","street_address"]]],[["places/ChIJGQn_o5KbEmsR8MrPvlTpFJo","ChIJGQn_o5KbEmsR8MrPvlTpFJo",["105 Hollinsworth Road, Marsden Park NSW, Australia",[[null,1]]],[["105 Hollinsworth Road",[[null,1]]],["Marsden Park NSW, Australia"]],["geocode","street_address"]]]]]';
  
  List<dynamic> results = jsonDecode(rawResponse);
  
  List<Map<String, String>> options = [];
  if (results.isNotEmpty && results[0] != null && results[0].isNotEmpty) {
    var placesArray = results[0][0];
    print('placesArray length: ${placesArray?.length}');
    for (var placeData in placesArray) {
      print('placeData length: ${placeData?.length}');
      if (placeData != null && placeData.length > 2) {
        final placeId = placeData[1]?.toString() ?? "";
        final text = placeData[2][0]?.toString() ?? "";
        options.add({"placeId": placeId, "text": text});
        print('Parsed: $text');
      }
    }
  }
  print('Total options: ${options.length}');
}
