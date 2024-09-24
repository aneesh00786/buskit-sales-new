import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/material.dart';

/// *********** General use Sizes  ***************

///===> [nkChildWrappedSizeBox] use to Wrap Containt child
SizedBox nkChildWrappedSizeBox({
  Widget? child,
  double? height,
  double? width,
}) =>
    SizedBox(
      height: height,
      width: width,
      child: child,
    );

SizedBox nkExtraSmallSizeBox({
  double? height,
  double? width,
  Widget? child,
}) =>
    SizedBox(
      height: height ?? AppDimensions.instance!.height * .08,
      width: width ?? AppDimensions.instance!.width * .08,
      child: child,
    );

SizedBox nkSmallSizeBox({
  double? height,
  double? width,
  Widget? child,
}) =>
    SizedBox(
      height: height ?? AppDimensions.instance!.height * .010,
      width: width ?? AppDimensions.instance!.width * .010,
      child: child,
    );

SizedBox nkMediumSizeBox({
  double? height,
  double? width,
  Widget? child,
}) =>
    SizedBox(
      height: height ?? AppDimensions.instance.height * .016,
      width: width ?? AppDimensions.instance.width * .016,
      child: child,
    );

SizedBox nkLargeSizeBox({
  double? height,
  double? width,
  Widget? child,
}) =>
    SizedBox(
      height: height ?? AppDimensions.instance!.height * .086,
      width: width ?? AppDimensions.instance!.width * .086,
      child: child,
    );

SizedBox nkExtraLargeSizeBox({
  double? height,
  double? width,
  Widget? child,
}) =>
    SizedBox(
      height: height ?? AppDimensions.instance!.height * .16,
      width: width ?? AppDimensions.instance!.width * .16,
      child: child,
    );

/// *********** General use Padding  ***************

EdgeInsets nkSmallPadding({
  double? top,
  double? right,
  double? bottom,
  double? left,
}) =>
    EdgeInsets.only(
      top: top ?? AppDimensions.instance!.height * .02,
      right: right ?? AppDimensions.instance!.width * .02,
      bottom: bottom ?? AppDimensions.instance!.height * .02,
      left: left ?? AppDimensions.instance!.width * .02,
    );

EdgeInsets nkMediumPadding({
  double? top,
  double? right,
  double? bottom,
  double? left,
}) =>
    EdgeInsets.only(
      top: top ?? AppDimensions.instance!.height * .04,
      right: right ?? AppDimensions.instance!.width * .04,
      bottom: bottom ?? AppDimensions.instance!.height * .04,
      left: left ?? AppDimensions.instance!.width * .04,
    );

EdgeInsets nkLargePadding({
  double? top,
  double? right,
  double? bottom,
  double? left,
}) =>
    EdgeInsets.only(
      top: top ?? AppDimensions.instance!.height * .012,
      right: right ?? AppDimensions.instance!.width * .012,
      bottom: bottom ?? AppDimensions.instance!.height * .012,
      left: left ?? AppDimensions.instance!.width * .012,
    );
EdgeInsets nkRegularPadding({
  double? top,
  double? right,
  double? bottom,
  double? left,
}) =>
    EdgeInsets.only(
      top: top ?? AppDimensions.instance.height * .010,
      right: right ?? AppDimensions.instance.width * .010,
      bottom: bottom ?? AppDimensions.instance.height * .010,
      left: left ?? AppDimensions.instance.width * .010,
    );

EdgeInsets nkExtraLargePadding({
  double? top,
  double? right,
  double? bottom,
  double? left,
}) =>
    EdgeInsets.only(
      top: top ?? AppDimensions.instance!.height * .14,
      right: right ?? AppDimensions.instance!.width * .14,
      bottom: bottom ?? AppDimensions.instance!.height * .14,
      left: left ?? AppDimensions.instance!.width * .14,
    );

EdgeInsets nkSymmetricPadding({
  double? horizontal,
  double? vertical,
}) =>
    EdgeInsets.symmetric(
      horizontal: horizontal ?? AppDimensions.instance!.width * .020,
      vertical: vertical ?? AppDimensions.instance!.height * .020,
    );
