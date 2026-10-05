import 'dart:convert';

void main() {
  String jsonStr = '[[[["places/ChIJ6eGAduD0k2sRBgoxPd2Ay1k","ChIJ6eGAduD0k2sRBgoxPd2Ay1k",["1 Ziviani Road, Wamuran QLD, Australia",[[null,1]]],[["1 Ziviani Road",[[null,1]]],["Wamuran QLD, Australia"]],["geocode","street_address"]]],[["places/ChIJL9jI4osd1moRVGTtT4KEhT4","ChIJL9jI4osd1moRVGTtT4KEhT4",["Costco Wholesale (under development, 130 Greenhills Road, Pakenham VIC, Australia",[[37,38]]],[["130 Greenhills Road",[[null,1]]],["Costco Wholesale (under development, Pakenham VIC, Australia"]],["street_address","geocode"]]]]]';
  
  List<dynamic> results = jsonDecode(jsonStr);
  
  var placesArray = results[0][0];
  for (var outerPlaceData in placesArray) {
    try {
      print("outerPlaceData type: \${outerPlaceData.runtimeType}");
      print("outerPlaceData[0] type: \${outerPlaceData[0].runtimeType}");
      print("outerPlaceData[0]: \${outerPlaceData[0]}");
      // Let's try to simulate the old logic and new logic
      var placeData = outerPlaceData[0]; // Is outerPlaceData[0] a String?
      // Yes, it is!
    } catch(e) {
      print(e);
    }
  }
}
