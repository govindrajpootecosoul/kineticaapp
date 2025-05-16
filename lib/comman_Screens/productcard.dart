// // lib/screens/sales/widgets/product_card.dart (optional: separate this file)
//
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';
//
// class ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//
//   const ProductCard({Key? key, required this.product}) : super(key: key);
//
//   Widget buildLabelValue(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           Text(value.toString(), style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Card(
//       color: AppColors.beige,
//       margin: const EdgeInsets.all(10),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               product['name']?.toString() ?? '',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment. spaceEvenly,
//               children: [
//
//                 // Flexible(
//                 //   flex: 3,
//                 //   child: Image.network(
//                 //     "https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200",
//                 //     height: 130,
//                 //     fit: BoxFit.fitHeight,
//                 //   ),
//                 // ),
//                 //const SizedBox(width: 10),
//                 Flexible(
//                   flex: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildLabelValue("SKU", product['SKU'] ?? "00"),
//                       buildLabelValue("Unit Ordered", product['Quantity'] ?? "00"),
//                       buildLabelValue("Organic Sales %", product['organicSales'] ?? "N/A"),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Flexible(
//                   flex: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildLabelValue("ASIN", product['asin'] ?? "00"),
//                      // buildLabelValue("Overall Sales", "\$${product['totalSalesamount'] ?? '00'}"),
//                       buildLabelValue(
//                         "Overall Sales",
//                         "£ ${(product['Total_Sales'] ?? 0).toDouble().toStringAsFixed(0)}",
//                       ),
//
//                       buildLabelValue("Return Revenue %", product['returnRevenue'] ?? 'N/A'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// lib/screens/sales/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  Widget buildLabelValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value.toString(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safely convert Total_Sales to double (handle int/double/null)
    final double totalSales = (product['Total_Sales'] as num?)?.toDouble() ?? 0.0;

    return Card(
      color: AppColors.beige,
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabelValue("SKU", product['SKU'] ?? "00"),
                      buildLabelValue("Unit Ordered", product['Quantity'] ?? "00"),
                      buildLabelValue("Organic Sales %", product['organicSales'] ?? "N/A"),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabelValue("ASIN", product['asin'] ?? "00"),
                      buildLabelValue("Overall Sales", "£ ${totalSales.toStringAsFixed(0)}"),
                      buildLabelValue("Return Revenue %", product['returnRevenue'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
