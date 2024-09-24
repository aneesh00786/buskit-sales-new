import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';

class TempHeadingUi extends StatelessWidget {
  final String tabName;
  const TempHeadingUi({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: nkRegularPadding(),
      child: Scaffold(
        body: Column(
          children: [
            MyRegularText(
              label: tabName,
              fontSize: NkFontSize.largeFont(),
            )
          ],
        ),
      ),
    );
  }
}
