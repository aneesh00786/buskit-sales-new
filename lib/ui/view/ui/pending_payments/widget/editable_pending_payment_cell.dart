// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EditablePendingPaymentCell extends StatefulWidget {
  final String initialValue;
  final Function(String, int) onValueChanged;
  final int index;
  final String orderId;
  final num orderTotal;
  // final num? receivable;
  final int? amountEdited;

  const EditablePendingPaymentCell({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
    required this.index,
    required this.orderId,
    required this.orderTotal,
    // this.receivable,
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
      text:
          // widget.receivable != null
          //     ? widget.receivable.toString() // Use receivable if not null
          // :
          widget.initialValue, // Otherwise, use initialValue
    );
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      };

      final response = await dio.post(
        '${ApiConstants.baseUrl}post_receivable_amount',
        data: data,
      );

      if (response.statusCode == 200) {
        // Success case
        final responseData = response.data;
        final message =
            responseData['message'] ?? 'Receivable amount updated successfully';

        showCustomToastDisplay(
          context,
          message,
          Colors.green,
          Icons.check_circle,
        );

      } else {
        // Error case with non-200 status
        final responseData = response.data;
        final message =
            responseData['message'] ?? 'Failed to update receivable amount';

        // Revert to original amount on error
        setState(() {
          _controller.text =
              // widget.receivable != null
              //     ? widget.receivable.toString()
              //     :
              widget.initialValue;
          isChanged = false;
        });

        showCustomToastDisplay(
          context,
          message,
          Colors.red,
          Icons.error,
        );

      }
    } catch (e) {
      // Exception case
      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          errorMessage =
              responseData['message'] ?? 'Failed to update receivable amount';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please try again.';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Request timeout. Please try again.';
        } else {
          errorMessage = 'Network error. Please check your connection.';
        }
      }

      // Revert to original amount on exception
      setState(() {
        _controller.text =
            // widget.receivable != null
            //     ? widget.receivable.toString()
            //     :
            widget.initialValue;
        isChanged = false;
      });

      showCustomToastDisplay(
        context,
        errorMessage,
        Colors.red,
        Icons.error,
      );

    }

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
              hintText:
                  // widget.receivable != null
                  //     ? widget.receivable.toString()
                  //     :
                  widget.initialValue,
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
