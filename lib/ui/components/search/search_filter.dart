
// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:flutter/material.dart';


class SearchFilter extends StatelessWidget {
  final void Function(String)? onChanged;
  final Future<List<String>> Function(String)? futureRequest;
  final Widget Function(BuildContext, String)? listItemBuilder;
  final TextEditingController searchTextController;
  const SearchFilter(BuildContext context, 
      {super.key,
      this.onChanged,
      this.futureRequest,
      this.listItemBuilder,
      required this.searchTextController});

  @override
  Widget build(BuildContext context) {
    return Container();

  }

  Widget simpleSearch() {
    return SearchBar(
      elevation: WidgetStateProperty.all(0),
      controller: searchTextController,
      backgroundColor:
          WidgetStateColor.resolveWith((states) => textFieldBgColor),
      hintText: search,
      hintStyle: WidgetStateProperty.all(
          TextStyle(color: secondaryTextColor.withOpacity(0.6))),
      trailing: const [
        Icon(
          Icons.search,
          size: 24,
        )
      ],
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
          side: const BorderSide(color: textFieldBgColor),
          borderRadius: BorderRadius.circular(
            NkGeneralSize.nkCommonBorderRadius(),
          ))),
      onChanged: onChanged,
    );
  }
}
