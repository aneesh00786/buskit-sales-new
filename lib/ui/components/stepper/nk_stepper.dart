import 'dart:math';

import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_selecteble_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';

class NkStepper extends StatefulWidget {
  final List<Step>? stepsData;
  final Widget Function(BuildContext, ControlsDetails)? controlsBuilder;
  final StepperType type;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? margin;
  final int currentStep;
  final void Function(int)? onStepTapped;
  final Widget? Function(int, StepState)? stepIconBuilder;
  const NkStepper(
      {super.key,
      this.stepsData,
      this.controlsBuilder,
      this.type = StepperType.vertical,
      this.physics,
      this.margin,
      this.currentStep = 0,
      this.onStepTapped,
      this.stepIconBuilder});

  @override
  State<NkStepper> createState() => _NkStepperState();
}

class _NkStepperState extends State<NkStepper> {
  @override
  void didUpdateWidget(covariant NkStepper oldWidget) {
    /* oldWidget.stepsData?.clear();
    oldWidget.stepsData?.addAll(widget.stepsData!)*/
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
        controlsBuilder: widget.controlsBuilder ??
            (BuildContext context, ControlsDetails details) {
              return Container();
            },
        key: Key(Random.secure().nextDouble().toString()),
        type: widget.type,
        stepIconBuilder: widget.stepIconBuilder,
        physics: widget.physics ??
            NkGeneralSize.commonPysics(
                physics: ClampingScrollPhysics(
                    parent: NkGeneralSize.commonPysics())),
        margin: widget.margin,
        currentStep: widget.currentStep,
        onStepTapped: widget.onStepTapped,
        steps: widget.stepsData ??
            <Step>[
              Step(
                title: MyRegularText(
                  label: "Step 1",
                  fontWeight: NkGeneralSize.nkBoldFontWeight(),
                  fontSize: (MediaQuery.of(
                      context)
                      .orientation ==
                      Orientation
                          .portrait)
                      ? (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 3
                      : 6)
                      : (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 6
                      : 10),

                ),
                content:  Column(
                  children: [
                    MyRegularSelectableText(
                      label: 'XYZ Shop, City',
                      fontSize: (MediaQuery.of(
                          context)
                          .orientation ==
                          Orientation
                              .portrait)
                          ? (ResponsiveInfo
                          .isMobileDimension(
                          context)
                          ? 3
                          : 6)
                          : (ResponsiveInfo
                          .isMobileDimension(
                          context)
                          ? 6
                          : 10),

                    ),

                  ],
                ),
              ),
              Step(
                title: MyRegularText(
                  label: "Step 2",
                  fontWeight: NkGeneralSize.nkBoldFontWeight(),
                  fontSize:(MediaQuery.of(
                      context)
                      .orientation ==
                      Orientation
                          .portrait)
                      ? (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 3
                      : 6)
                      : (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 6
                      : 10),
                ),
                content:  Column(
                  children: [
                    MyRegularSelectableText(
                      label: 'XYZ Shop, City',
                      fontSize: (MediaQuery.of(
                          context)
                          .orientation ==
                          Orientation
                              .portrait)
                          ? (ResponsiveInfo
                          .isMobileDimension(
                          context)
                          ? 3
                          : 6)
                          : (ResponsiveInfo
                          .isMobileDimension(
                          context)
                          ? 6
                          : 10),
                    ),

                  ],
                ),
              ),
            ]);
  }
}
