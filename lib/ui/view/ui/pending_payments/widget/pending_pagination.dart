// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class PaginationWidget extends StatefulWidget {
  const PaginationWidget({super.key});

  @override

  _PaginationWidgetState createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  int currentPage = 1;
  final int totalPages = 3;

  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void goToNextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: totalPages > 0 ? totalPages * 62.0 : 0,
      decoration: BoxDecoration(
        color: primaryColor, 
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_double_arrow_left,
                size: 20,
                color: Colors.white,
              ),
              onPressed: goToPreviousPage,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(totalPages, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPage = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      height: 40,
                      width: 25,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: currentPage == index + 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            color: currentPage == index + 1 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_double_arrow_right,
                size: 20,
                color: Colors.white,
              ),
              onPressed: goToNextPage,
            ),
          ),
        ],
      ),
    );
  }
}
