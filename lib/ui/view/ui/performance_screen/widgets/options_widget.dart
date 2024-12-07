import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/option_container.dart';
import 'package:flutter/material.dart';

class OptionsWidget extends StatelessWidget {
  final List<OptionData> options;

  const OptionsWidget({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: options.map((e) {
        return GestureDetector(
          onTap: e.onTap,
          child: PerformanceWidget(
            title: e.title,
            count: e.count,
            svg: e.svg,
            svgBgColor: e.svgBgColor,
          ),
        );
      }).toList(),
    );
  }
}