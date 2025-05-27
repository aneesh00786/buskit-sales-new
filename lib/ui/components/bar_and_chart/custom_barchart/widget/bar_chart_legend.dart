import 'package:flutter/material.dart';

class BarChartLegend extends StatelessWidget {
  final bool isDayOrRange;
  final String staffProjection;

  const BarChartLegend({
    super.key,
    required this.isDayOrRange,
    required this.staffProjection,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isDayOrRange)
          LegendItem(color: const Color(0xff3b6491), label: 'Target'),
        if (!isDayOrRange && staffProjection == "1")
          LegendItem(color: const Color(0xff15396a), label: 'Projection'),
        LegendItem(color: const Color(0xff7a8f3d), label: 'Actuals'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}