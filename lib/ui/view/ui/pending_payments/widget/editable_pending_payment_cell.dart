// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EditablePendingPaymentCell extends StatefulWidget {
  final String initialValue;
  final Function(String, int) onValueChanged;
  final int index;
  final String orderId;
  final num orderTotal;
  final num? receivable;
  final int? amountEdited;

  const EditablePendingPaymentCell({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
    required this.index,
    required this.orderId,
    required this.orderTotal,
    this.receivable,
    this.amountEdited,
  });

  @override
  _EditablePendingPaymentCellState createState() =>
      _EditablePendingPaymentCellState();
}

class _EditablePendingPaymentCellState
    extends State<EditablePendingPaymentCell> {
  late TextEditingController _controller;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.receivable != null
          ? widget.receivable.toString() // Use receivable if not null
          : widget.initialValue, // Otherwise, use initialValue
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue() async {
    setState(() {
      isChanged = false; // Reset change state after saving
    });

    try {
      final dio = Dio(); // Initialize Dio

      // Prepare data for API call
      final data = {
        "order_id": widget.orderId, // Use the orderId passed to the widget
        "amount": double.tryParse(_controller.text) ?? 0,
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      };

      final response = await dio.post(
        '${ApiConstants.baseUrl}post_receivable_amount',
        data: data,
      );

      if (response.statusCode == 200) {
      } else {}
    // ignore: empty_catches
    } catch (e) {}

    widget.onValueChanged(_controller.text, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    bool isReceivableDifferent = widget.amountEdited == 1 ? true : false;
    return Row(
      children: [
        Text(addCurrencySymbol()),
        const SizedBox(width: 5),
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
              fillColor: isChanged || isReceivableDifferent
                  ? Colors.green[100]
                  : Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: widget.receivable != null
                  ? widget.receivable.toString()
                  : widget.initialValue,
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
