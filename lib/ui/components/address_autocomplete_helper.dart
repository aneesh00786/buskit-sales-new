import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';

class AddressAutocompleteHelper {
  static Widget buildAddressAutocompleteField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required Widget prefixIcon,
    required Function(String placeId, String fullText) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<Map<String, String>>(
              focusNode: focusNode,
              textEditingController: controller,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, String>>.empty();
                }
                final results = await ApiWorker().getPlacesAutocomplete(textEditingValue.text);
                final List<Map<String, String>> options = [];
                
                if (results.isNotEmpty && results[0] != null && results[0].isNotEmpty) {
                  final placesArray = results[0];
                  print('API Results length: ${results.length}, placesArray length: ${placesArray?.length}');
                  if (placesArray != null) {
                    for (var outerPlaceData in placesArray) {
                      try {
                        if (outerPlaceData != null && outerPlaceData.isNotEmpty) {
                          var placeData = outerPlaceData[0];
                          if (placeData != null && placeData.length > 2) {
                            final placeId = placeData[1]?.toString() ?? "";
                            final text = placeData[2][0]?.toString() ?? "";
                            options.add({"placeId": placeId, "text": text});
                            print('Parsed option: $text');
                          }
                        }
                      } catch (e) {
                        print("Error parsing placeData: $e");
                      }
                    }
                  }
                  print('Total options added: ${options.length}');
                }
                return options;
              },
              displayStringForOption: (Map<String, String> option) => option['text'] ?? '',
              fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    prefixIcon: prefixIcon,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelectedOption, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: const BoxConstraints(maxHeight: 168.0),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option['text'] ?? ''),
                            onTap: () {
                              onSelectedOption(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (Map<String, String> selection) {
                focusNode.unfocus();
                onSelected(selection['placeId'] ?? '', selection['text'] ?? '');
              },
            );
          }
        ),
      ),
    );
  }

  static Future<void> fillAddressDetails(
    String placeId,
    String fullText,
    TextEditingController addressController,
    TextEditingController townController,
    TextEditingController stateController,
    TextEditingController zipCodeController,
    TextEditingController countryController,
  ) async {
    final parts = fullText.split(',');
    if (parts.isNotEmpty) addressController.text = parts[0].trim();
    if (parts.length > 1) townController.text = parts[1].trim();
    if (parts.length > 2) stateController.text = parts[2].trim();

    final details = await ApiWorker().getPlaceDetails(placeId);
    if (details != null && details['address_components'] != null) {
      final components = details['address_components'] as List;
      for (var component in components) {
        final types = component['types'] as List;
        if (types.contains('postal_code')) {
          zipCodeController.text = component['long_name'];
        }
        if (types.contains('administrative_area_level_1')) {
          stateController.text = component['long_name'];
        }
        if (types.contains('locality')) {
          townController.text = component['long_name'];
        }
        if (types.contains('country')) {
          countryController.text = component['long_name'];
        }
      }
    }
  }
}
