import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/null_check_oprations.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_progress_indicatorz.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final Color? color;
  final Alignment alignment;
  final BoxFit? fit;
  // ignore: prefer_typing_uninitialized_variables
  final cacheManager;
  final LoadingErrorWidgetBuilder? errorWidget;
  final PlaceholderWidgetBuilder? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final ImageWidgetBuilder? imageBuilder;
  final bool withoutBaseUrl;

  const MyNetworkImage(
      {super.key,
      required this.imageUrl,
      this.width,
      this.height,
      this.color,
      this.alignment = Alignment.center,
      this.fit,
      this.cacheManager,
      this.errorWidget,
      this.placeholder,
      this.progressIndicatorBuilder,
      this.imageBuilder,
      this.withoutBaseUrl = false});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: CheckNullData.checkLocalOrServerImage(imageUrl) == false
          ? ApiConstants.imageBaseUrl + imageUrl.toString()
          : imageUrl,
      height: height,
      width: width,
      color: color,
      alignment: alignment,
      fit: fit ?? BoxFit.cover,
      cacheManager: cacheManager,
      errorWidget: errorWidget ??
          (context, url, error) {
            return NkCommonFunction.errorWidget();
          },
      imageBuilder: imageBuilder,
      placeholder: placeholder ??
          (context, url) {
            return const MyProgressIndicator();
          },
      progressIndicatorBuilder: progressIndicatorBuilder,
    );
  }
}
