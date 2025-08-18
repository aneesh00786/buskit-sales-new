// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/currency_uinit.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_textfield.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressSearchField extends StatefulWidget {
  final String hinttext;
  final TextEditingController textEditingController;
  final TextEditingController townController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController postCodeController;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;
  final LoginController loginController;

  const AddressSearchField({
    super.key,
    required this.hinttext,
    required this.textEditingController,
    required this.townController,
    required this.stateController,
    required this.countryController,
    required this.currentFocusNode,
    required this.nextFocusNode,
    required this.loginController,
    required this.postCodeController,
  });

  @override
  _AddressSearchFieldState createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  Timer? _debounce;
  List<Map<String, dynamic>> suggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  bool isAddressSelected = false;
  bool isPhoneNumberValid = false;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      onAddressChanged(widget.textEditingController.text);
    });
  }

  void onAddressChanged(String value) {
    if (isAddressSelected) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (value.isNotEmpty) {
        fetchAddressSuggestions(value);
      } else {
        setState(() {
          suggestions = [];
        });
        hideSuggestionsOverlay();
      }
    });
  }

  Future<void> fetchAddressSuggestions(String query) async {
    final url =
        Uri.parse("${ApiConstants.baseUrl}search-address?query=$query");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          suggestions = data.map((item) {
            return {
              'description': item['description'],
              'place_id': item['place_id'],
              'secondary_text': item['structured_formatting']['secondary_text'],
            };
          }).toList();
        });
        if (suggestions.isNotEmpty) {
          showSuggestionsOverlay();
        }
      } else {
        log("Error: ${response.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
    }
  }

  void showSuggestionsOverlay() {
    hideSuggestionsOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final RenderBox renderBox =
            _textFieldKey.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        return Positioned(
          width: size.width,
          left: offset.dx,
          top: offset.dy + size.height,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4,
              child: Container(
                constraints: BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  color: Colors.white,
                ),
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      title: Text(suggestion['description']),
                      onTap: () async {
                        isAddressSelected = true;
                        final placeId = suggestion['place_id'];
                        final structuredFormatting =
                            suggestion['structured_formatting'];
                        final mainText = structuredFormatting != null
                            ? structuredFormatting['main_text'] ??
                                suggestion['description']
                                    .toString()
                                    .split(',')
                                    .first
                            : suggestion['description']
                                .toString()
                                .split(',')
                                .first;
                        widget.textEditingController.text = mainText;
                        await fetchPlaceDetails(placeId);
                        hideSuggestionsOverlay();
                        widget.nextFocusNode.requestFocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.textEditingController.removeListener(() {
      onAddressChanged(widget.textEditingController.text);
    });
    hideSuggestionsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: RegisterTextField(
        hinttext: widget.hinttext,
        key: _textFieldKey,
        icon: const Icon(EneftyIcons.buildings_outline),
        textEditingController: widget.textEditingController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Business name';
          }

          return null;
        },
        focusNode: widget.currentFocusNode,
        onChanged: (value) {
          if (isAddressSelected) {
            setState(() {
              isAddressSelected = false;
            });
          }
        },
      ),
    );
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    final url =
        Uri.parse("${ApiConstants.baseUrl}get-place-details?place_id=$placeId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        extractAndPopulateFields(data);
      } else {
        log("Place details error: ${response.statusCode}");
      }
    } catch (e) {
      log("Place details exception: $e");
    }
  }

  void extractAndPopulateFields(Map<String, dynamic>? data) {
    if (data == null) return;

    final town = data['town']?.toString() ?? '';
    final state = data['state']?.toString() ?? '';
    final country = data['country_name']?.toString() ?? '';
    final postCode = data['postal_code']?.toString() ?? '';
    final phoneCode = CurrencyUtils.countryCurrencyMap.entries
            .firstWhere(
              (entry) => entry.value['name'] == country,
              orElse: () => MapEntry("", {"phoneCode": ""}),
            )
            .value['phoneCode'] ??
        '';
    widget.townController.text = town;
    widget.stateController.text = state;
    widget.countryController.text = country;
    widget.postCodeController.text = postCode;
    widget.loginController.updatePhoneCode(phoneCode);
  }
}
