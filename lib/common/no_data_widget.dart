import 'package:flutter/material.dart';

class NodataWidget extends StatelessWidget {
  const NodataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 50, color: Colors.grey),
              Text('No data available'),
            ],
          ),
        );
  }
}