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
    const Color statusColor = Color(0xFFDC2626);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: _expanded ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            if (_expanded) ...[
              const SizedBox(width: 7),
              Text(
                "Out of Stock".tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
