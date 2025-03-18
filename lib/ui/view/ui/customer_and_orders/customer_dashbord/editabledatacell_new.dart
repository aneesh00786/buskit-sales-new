// ignore_for_file: empty_catches

import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EditableDataCell extends StatefulWidget {
  final String initialValue;
  final Function(String, int) onValueChanged;
  final int index;
  final String orderId; 
  final num orderTotal;

  const EditableDataCell({super.key, 
    required this.initialValue,
    required this.onValueChanged,
    required this.index,
    required this.orderId, 
    required this.orderTotal,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditableDataCellState createState() => _EditableDataCellState();
}

class _EditableDataCellState extends State<EditableDataCell> {
  late TextEditingController _controller;
  bool isChanged = false;
  final companyId = SessionHelper.loginSavedData?.company_id??0;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue() async {
    setState(() {
      isChanged = false;
    });

    try {
      final dio = Dio();
      final data = {
        "order_id": widget.orderId,
        "amount": double.tryParse(_controller.text) ?? 0,
        "companyId": companyId
      };
      final response = await dio.post(
        'http://16.50.232.153:3000/post_receivable_amount',
        data: data,
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }

    widget.onValueChanged(_controller.text, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    bool isTotalDifferent = double.tryParse(_controller.text) != widget.orderTotal;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                isChanged = value.isNotEmpty && value != widget.initialValue;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: isChanged || isTotalDifferent ? Colors.green[100] : Colors.white, // Compare the orderTotal here
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: widget.initialValue,
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 10.0,
              ),
            ),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
        if (isChanged)
          Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3, left: 5),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _updateValue();
                },
                icon: const Icon(
                  Icons.save,
                  color: primaryColor,
                  size: 14.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
