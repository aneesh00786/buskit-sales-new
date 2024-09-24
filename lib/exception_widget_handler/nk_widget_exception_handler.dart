import 'dart:async';
import 'dart:developer';

import 'package:busskit_salesexecutive/exception_widget_handler/nk_connectivity_error_handler.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_progress_Indicator.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';

class NkWidgetExceptionHandel extends StatefulWidget {
  final dynamic data;
  final Widget child;
  final double? height;
  final double? width;
  final bool? isCenter;
  final bool isShowProgress;
  final Widget? replaceWidget;
  final Widget? errorCustomWidgets;
  final bool isShowRetrySection;
  final void Function()? onRetryPressed;

  const NkWidgetExceptionHandel(
      {Key? key,
      required this.data,
      required this.child,
      this.height,
      this.width,
      this.isCenter,
      this.isShowProgress = true,
      this.onRetryPressed,
      this.isShowRetrySection = true,
      this.replaceWidget,
      this.errorCustomWidgets})
      : super(key: key);

  @override
  State<NkWidgetExceptionHandel> createState() =>
      _NkWidgetExceptionHandelState();
}

class _NkWidgetExceptionHandelState extends State<NkWidgetExceptionHandel> {
  StreamController<dynamic>? _streamController;
  Timer? _timer;
  int _attemt = 0;

  @override
  void initState() {
    inisilizedStream;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.isActive ?? false ? _timer!.cancel() : null;
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _streamControllerValueIsEmpty(widget.data);
    return StreamBuilder(
        stream: _streamController!.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _attemt >= 3 && widget.isShowRetrySection
                ? widget.errorCustomWidgets ??
                    NkConnectivityErrorHandler(
                      onRetryPressed: () {
                        widget.onRetryPressed?.call();
                        setState(() {
                          _attemt = 0;
                        });
                        _timerCallback;
                      },
                    )
                : Visibility(
                    visible: false,
                    replacement: widget.replaceWidget ?? const SizedBox(),
                    child: widget.child,
                  );
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return _emptyDataWidget(isCenter: widget.isCenter);

              case ConnectionState.waiting:
                return widget.isShowProgress
                    ? _loadingDataWidget(
                        height: widget.height,
                        width: widget.width,
                        context: context,
                        isCenter: widget.isCenter)
                    : const SizedBox();

              case ConnectionState.active:
                return widget.child;
              case ConnectionState.done:
                return widget.child;
              /* return widget.child;*/
              default:
                return _emptyDataWidget(isCenter: widget.isCenter);
            }
          }
        });
  }

  // user for when data is empty

  Widget _emptyDataWidget({bool? isCenter = false}) {
    return isCenter ?? false
        ? Center(
            child: MyRegularText(
              label: 'No Data Yet...!',
              fontSize: widget.height ?? 16,
              align: TextAlign.justify,
              fontWeight: FontWeight.bold,
            ),
          )
        : MyRegularText(
            label: 'No Data Yet...!',
            fontSize: widget.height ?? 16,
            fontWeight: FontWeight.bold,
            align: TextAlign.justify,
          );
  }

  // when data is loading stage
  static Widget _loadingDataWidget(
      {double? height,
      double? width,
      bool? isCenter = false,
      required BuildContext context}) {
    return isCenter ?? false
        ? Center(
            child: SizedBox(
              height: height ?? MediaQuery.of(context).size.height * 0.1,
              width: width,
              child: const MyProgressIndicator(),
            ),
          )
        : SizedBox(
            height: height ?? MediaQuery.of(context).size.height * 0.1,
            width: width,
            child: const MyProgressIndicator(),
          );
  }

  void get inisilizedStream async {
    _streamController = StreamController();
    await Future.delayed(const Duration(milliseconds: 50));
    _streamControllerValueIsEmpty(widget.data);

    _timerCallback;
  }

  /// [_timerCallback] 3 attempt when data is empty to retry button show
  get _timerCallback => _timer =
          Timer.periodic(Duration(milliseconds: (_attemt + 1) * 300), (timer) {
        if (_attemt >= 3 || !widget.isShowRetrySection) {
          log("Timer Cancel ${_attemt}");
          _timer!.cancel();
          _streamControllerValueIsEmpty(widget.data);
          return;
        }
        _streamControllerValueIsEmpty(widget.data);
      });

  _streamControllerValueIsEmpty(value) {
    if (isNullEmptyOrFalse(value)) {
      _attemt++;
      _attemt >= 3 ? _streamController!.addError('No Data Yet...!') : null;
      //log("ATTEPT CHEK ${_attemt}");
    } else {
      _streamController!.add(widget.data);
    }
  }

  bool isNullEmptyOrFalse(dynamic o) {
    if (o is Map<String, dynamic> || o is List<dynamic>) {
      return o == null || o.length == 0;
    }
    return o == null || false == o || "" == o;
  }
}
