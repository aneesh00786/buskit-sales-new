import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          Icon(Icons.info_outline, size: 50, color: Colors.grey),
          Text('No data available'),
        ],
      ),
    );
  }
}

class LoadingToNoDataWidget extends StatelessWidget {
  final Color spinnerColor;
  final double spinnerSize;
  final Duration delayDuration;

  const LoadingToNoDataWidget({
    Key? key,
    this.spinnerColor = Colors.blue,
    this.spinnerSize = 20.0,
    this.delayDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delayDuration),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCube(
              color: primaryColor,
              size: spinnerSize,
            ),
          );
        } else {
          return Center(child: NodataWidget());
        }
      },
    );
  }
}
