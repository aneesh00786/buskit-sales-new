import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EditablePendingPaymentCell extends StatefulWidget {
  final String initialValue;
  final Function(String, int) onValueChanged;
  final int index;
  final String orderId;
  final int orderTotal;
  final int? receivable; // Nullable receivable

  EditablePendingPaymentCell({
    required this.initialValue,
    required this.onValueChanged,
    required this.index,
    required this.orderId,
    required this.orderTotal,
    this.receivable, // Nullable receivable
  });

  @override
  _EditablePendingPaymentCellState createState() => _EditablePendingPaymentCellState();
}

class _EditablePendingPaymentCellState extends State<EditablePendingPaymentCell> {
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
      };

      // Make the API call
      final response = await dio.post(
        'http://16.50.232.153:3000/post_receivable_amount', // Replace with your API endpoint
        data: data,
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('API call successful');
        // Optionally, handle the successful response here
      } else {
        print('API call failed with status code: ${response.statusCode}');
        // Optionally, handle error response here
      }
    } catch (e) {
      print('Error making API call: $e');
      // Optionally, handle exceptions here
    }

    // Notify the parent widget about the value change
    widget.onValueChanged(_controller.text, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    // Safely check if receivable is null or different from orderTotal
    bool isReceivableDifferent = widget.receivable != null && widget.receivable != widget.orderTotal;

    return Row(
      children: [
        Text(addCurrencySymbol()),
        SizedBox(width: 5),
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
              // Fill with green if receivable is different from orderTotal or if value has changed
              fillColor: isChanged || isReceivableDifferent ? Colors.green[100] : Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.0),
              ),
              // Display receivable in hintText if it's not null, otherwise display initialValue
              hintText: widget.receivable != null ? widget.receivable.toString() : widget.initialValue,
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 10.0,
              ),
            ),
            style: TextStyle(
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
                icon: Icon(
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
