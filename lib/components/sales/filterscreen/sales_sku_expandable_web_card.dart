import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';

class SalesSkuExpandableWebCard extends StatefulWidget {
  final Map<String, dynamic> item;

  const SalesSkuExpandableWebCard({super.key, required this.item});

  @override
  State<SalesSkuExpandableWebCard> createState() => _SalesSkuExpandableWebCardState();
}

class _SalesSkuExpandableWebCardState extends State<SalesSkuExpandableWebCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final records = item['records'] as List<dynamic>;

    return GestureDetector(
      onTap: _toggleExpand,
      child: Card(
        color: AppColors.beige,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SKU: ${item['SKU']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Sold Qty: ${item['totalQuantity']}", style: const TextStyle(fontSize: 13)),
                  Text("Revenue £${(item['totalSales'] as num).toStringAsFixed(2)}", style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),

              /// Expanded Detail
              if (_isExpanded) ...[
                const Divider(),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final record = records[i];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.beige,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Product: ${record['productName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Product Category: ${record['productCategory']}"),
                          // Text("Purchase Date: ${record['purchaseDate'].split("T")[0]}"),
                          // Text("Status: ${record['orderStatus']}"),
                          // Text("Quantity: ${record['quantity']}"),
                          Text("Revenue: £${(record['totalSales'] as num).toStringAsFixed(2)}"),
                        ],
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
