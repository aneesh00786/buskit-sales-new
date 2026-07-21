import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoStockStatusChip extends StatefulWidget {
  const PromoStockStatusChip({super.key});

  @override
  State<PromoStockStatusChip> createState() => _PromoStockStatusChipState();
}

class _PromoStockStatusChipState extends State<PromoStockStatusChip>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.red.shade400,
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: _expanded ? 16 : 10,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 255, 203, 203), // Light red
                  Color.fromARGB(255, 255, 185, 185), // Slightly darker light red
                ],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 5,
                ),
                if (_expanded) ...[
                  const SizedBox(width: 8),
                  Text(
                    "Out of Stock".tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}