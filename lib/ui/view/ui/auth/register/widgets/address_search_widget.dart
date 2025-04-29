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

  AddressSearchField({
    Key? key,
    required this.hinttext,
    required this.textEditingController,
    required this.townController,
    required this.stateController,
    required this.countryController,
  }) : super(key: key);

  @override
  _AddressSearchFieldState createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  Timer? _debounce;
  List<Map<String, dynamic>> suggestions = [];
  bool isAddressSelected = false;

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
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterTextField(
          hinttext: widget.hinttext,
          icon: const Icon(EneftyIcons.buildings_outline),
          textEditingController: widget.textEditingController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your Business name';
            }

            return null;
          },
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion['description']),
                  onTap: () {
                    widget.textEditingController.text =
                        suggestion['description'];
                    final terms = suggestion['terms'] as List;
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
                    setState(() {
                      suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
