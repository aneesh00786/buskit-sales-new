
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/return_info_model.dart';
import 'package:flutter/material.dart';

          // <-- your controller file





class PendingReturnsPopup extends StatelessWidget {
  final String productName;
  final String variationName;
  final List<ReturnInfoData> returnItems;
   PendingReturnsPopup({super.key,
  required this.productName,
    required this.variationName,
    required this.returnItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Return Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.blue),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Product Title
          Text(
            '$productName – $variationName – Pending Returns',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFFF5F5F5),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TableHeaderText('Return ID')),
                Expanded(flex: 1, child: _TableHeaderText('Qty')),
                Expanded(flex: 2, child: _TableHeaderText('Reason')),
                Expanded(flex: 2, child: _TableHeaderText('Date')),
                Expanded(flex: 2, child: _TableHeaderText('Return Type')),
                Expanded(flex: 2, child: _TableHeaderText('Status')),
              ],
            ),
          ),

          // Table Rows
           if (returnItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No pending returns')),
            )
          else
            ...returnItems.map((item) {
              return Column(
                children: [
                  _ReturnRow(
                    id: item.returnId,
                    qty: item.returnQuantity.toString(),
                    reason: item.itemReturnReason,
                    date: _formatDate(item.createdAt),
                    type: item.returnType,
                    status: item.returnStatus,
                  ),
                  const Divider(height: 1, color: Colors.grey),
                ],
              );
            }).toList(),

          const SizedBox(height: 24),
         
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6c757d),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
   String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }


class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ReturnRow extends StatelessWidget {
  final String id, qty, reason, date, type, status;

  const _ReturnRow({
    required this.id,
    required this.qty,
    required this.reason,
    required this.date,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: _CellText(id)),
          Expanded(flex: 1, child: _CellText(qty)),
          Expanded(flex: 2, child: _CellText(reason)),
          Expanded(flex: 2, child: _CellText(date)),
          Expanded(flex: 2, child: _CellText(type)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF856404),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  const _CellText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
