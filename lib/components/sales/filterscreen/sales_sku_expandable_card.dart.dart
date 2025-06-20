import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';

class SalesSkuExpandableCard extends StatefulWidget {
  final Map<String, dynamic> item;

  const SalesSkuExpandableCard({super.key, required this.item});

  @override
  State<SalesSkuExpandableCard> createState() => _SalesSkuExpandableCardState();
}

class _SalesSkuExpandableCardState extends State<SalesSkuExpandableCard> {
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
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Collapsed Summary
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, i) {
                    final record = records[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.beige,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          //   Text("Product: ${record['productName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          //   Text("Order ID: ${record['orderID']}"),
                          //   Text("Purchase Date: ${record['purchaseDate'].split("T")[0]}"),
                          //   Text("Status: ${record['orderStatus']}"),
                          //  // Text("Quantity: ${record['quantity']}"),
                          //   Text("Unit Selling Price: £${(record['totalSales'] as num).toStringAsFixed(2)}"),

                          Text("Product: ${record['productName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                           Text("Product Category: ${record['productCategory']}"),
                          // Text("Purchase Date: ${record['purchaseDate'].split("T")[0]}"),
                          // Text("Status: ${record['orderStatus']}"),
                          // Text("Quantity: ${record['quantity']}"),
                          Text("Revenue: £${(record['totalSales'] as num).toStringAsFixed(2)}"),
                          ],
                        ),
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
