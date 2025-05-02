import 'dart:async';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
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
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;

  AddressSearchField({
    Key? key,
    required this.hinttext,
    required this.textEditingController,
    required this.townController,
    required this.stateController,
    required this.countryController,
    required this.currentFocusNode,
    required this.nextFocusNode,
  }) : super(key: key);

  @override
  _AddressSearchFieldState createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  Timer? _debounce;
  List<Map<String, dynamic>> suggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  bool isAddressSelected = false; // Address selection flag
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode nextFieldFocusNode = FocusNode();

  void onAddressChanged(String value) {
    if (isAddressSelected) {
      return; // Stop API calls if an address is selected
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
        Uri.parse("https://test.thrivewoo.com/search-address?query=$query");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          suggestions = data.map((item) {
            return {
              'description': item['description'],
              'secondary_text': item['structured_formatting']['secondary_text'],
              'terms': item['terms'] as List,
            };
          }).toList();
        });
        if (suggestions.isNotEmpty) {
          showSuggestionsOverlay();
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
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
                      onTap: () {
                        isAddressSelected = true; // Mark address as selected
                        widget.textEditingController.text =
                            suggestion['description'];
                        populateAdditionalFields(suggestion['terms'] as List);
                        hideSuggestionsOverlay();
                        widget.nextFocusNode
                            .requestFocus(); // Move to next field
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

  void populateAdditionalFields(List terms) {
    String town = '';
    String state = '';
    String country = '';
    if (terms.isNotEmpty) {
      if (terms.length >= 3) {
        town = terms[terms.length - 3]['value'];
        state = terms[terms.length - 2]['value'];
        country = terms[terms.length - 1]['value'];
      } else if (terms.length == 2) {
        state = terms[0]['value'];
        country = terms[1]['value'];
      } else if (terms.length == 1) {
        country = terms[0]['value'];
      }
    }
    widget.townController.text = town;
    widget.stateController.text = state;
    widget.countryController.text = country;
  }

  void hideSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      onAddressChanged(widget.textEditingController.text);
    });
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
}
