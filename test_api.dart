import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final query = "sydney";
  final payload = jsonEncode([
    "1",
    null,
    null,
    ["street_address"],
    ["AU"],
    "en-US",
    null,
    null,
    null,
    null,
    query
  ]);

  final dio = Dio();
  try {
    final response = await dio.post(
      "https://places.googleapis.com/\$rpc/google.maps.places.v1.Places/AutocompletePlaces",
      data: payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json+protobuf',
          'X-Goog-Api-Key': 'AIzaSyC8E9zV-5yGKWKqeBuIicx2Ma40cnXJsoc',
        },
        responseType: ResponseType.plain,
      ),
    );
    String rawResponse = response.data.toString();
    if (rawResponse.startsWith(")]}'\n")) {
      rawResponse = rawResponse.substring(5);
    }
    List<dynamic> results = jsonDecode(rawResponse);
    if (results.isNotEmpty) {
      print("Full JSON structure:");
      print(jsonEncode(results));
    }
  } catch (e) {
    print('Error: $e');
  }
}
