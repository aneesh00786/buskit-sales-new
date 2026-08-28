import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:get/get.dart';

class SalesmanTargetByCategoryDialog extends StatefulWidget {
  final String title;
  final DashboardProvider provider;

  const SalesmanTargetByCategoryDialog(
      {super.key, required this.title, required this.provider});

  @override
  State<SalesmanTargetByCategoryDialog> createState() =>
      _SalesmanTargetByCategoryDialogState();
}

class _SalesmanTargetByCategoryDialogState
    extends State<SalesmanTargetByCategoryDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildTable(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                widget.title.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.all(12.0),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFE2E8F0)),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
            children: [
              _buildTableHeader('Month'.tr),
              if (widget.title == 'Target') _buildTableHeader('Target'.tr),
              if (widget.title == 'Projection') _buildTableHeader('Projection'.tr),
            ],
          ),
          ..._buildDataRows(),
        ],
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    final keys = widget.provider.salesmanTargetByCategory;
    return List.generate(keys.length, (index) {
      return TableRow(
        children: [
          _buildTableCell(keys[index].month.toString()),
          if (widget.title == 'Target')
            _buildTableCell(formatAmount(keys[index].target)),
          if (widget.title == 'Projection')
            _buildTableCell(formatAmount(keys[index].projection)),
        ],
      );
    });
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins_Regular',
          color: Color(0xFF0F172A),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return SizedBox(
      height: 44,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: Color(0xFF0F172A),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
