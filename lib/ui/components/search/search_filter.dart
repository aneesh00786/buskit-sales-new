import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFilter extends StatelessWidget {
  final void Function(String)? onChanged;
  final Future<List<String>> Function(String)? futureRequest;
  final Widget Function(BuildContext, String)? listItemBuilder;
  final TextEditingController searchTextController;
  const SearchFilter(BuildContext context, 
      {Key? key,
      this.onChanged,
      this.futureRequest,
      this.listItemBuilder,
      required this.searchTextController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
    // return CustomDropdown.searchRequest(
    //   controller: searchTextController,
    //   onChanged: (p0) {
    //     onChanged?.call(p0);
    //   },
    //   selectedStyle: Get.theme.textTheme.bodyMedium,
    //   listItemBuilder: listItemBuilder,
    //   hintText: search,
    //   borderRadius: BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
    //   fieldSuffixIcon: const Icon(Icons.search),
    //   futureRequest: (string) => futureRequest!(string),
    // );
  }

  Widget simpleSearch() {
    return SearchBar(
      elevation: MaterialStateProperty.all(0),
      controller: searchTextController,
      backgroundColor:
          MaterialStateColor.resolveWith((states) => textFieldBgColor),
      hintText: search,
      hintStyle: MaterialStateProperty.all(
          TextStyle(color: secondaryTextColor.withOpacity(0.6))),
      trailing: const [
        Icon(
          Icons.search,
          size: 24,
        )
      ],
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          side: const BorderSide(color: textFieldBgColor),
          borderRadius: BorderRadius.circular(
            NkGeneralSize.nkCommonBorderRadius(),
          ))),
      onChanged: onChanged,
    );
  }
}
