import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final void Function(int quantity)? onChanged;

  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onChanged?.call(_quantity);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onChanged?.call(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: _decrement,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.blue),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.remove_circle_outline,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Text(
          '$_quantity',
          style: const TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: _increment,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.blue),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.add_circle_outline,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}