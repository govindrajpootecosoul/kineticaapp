import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductInfoCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat.decimalPattern(); // for commas

    return Card(
      color: const Color(0xFFF7EFD7),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/product.jpg",
                height: 110,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Kinetica Sports Strawberry Whey Protein Powder | 4.5kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Info Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabelValue("SKU", product["SKU"].toString()),
                            _buildLabelValue("Sales", formatNumber.format(product["Total Sales"])),
                            _buildLabelValue("CM2", _formatCurrency(product["CM2"])),
                          ],
                        ),
                      ),
                      // Column 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabelValue("ASIN", "BOCDWJJ8CK"),
                            _buildLabelValue("CM1", _formatCurrency(product["CM1"])),
                            _buildLabelValue("CM3", _formatCurrency(product["CM3"])),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(
              text: "$label\n",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    final number = value is num ? value.round() : 0;
    final formatted = NumberFormat.decimalPattern().format(number);
    return '£ $formatted';
  }
}
