// lib/screens/inventory/product_card.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class InventorySkuCardScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const InventorySkuCardScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<InventorySkuCardScreen> createState() => _InventorySkuCardScreenState();
}

class _InventorySkuCardScreenState extends State<InventorySkuCardScreen> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget buildLabelValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value.toString(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildLabelValueExpend(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        //color: const Color(0xECD5B0),
        color: Colors.white60,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: _toggleExpand,
      child: Card(
        color: AppColors.beige,
        margin: const EdgeInsets.all(10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   product['SKU']?.toString() ?? '',
              //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),

              // Text(
              //   product['Date']?.toString() ?? '',
              //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flexible(
                  //   flex: 3,
                  //   child: Image.network(
                  //     "https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200",
                  //     height: 130,
                  //     fit: BoxFit.fitHeight,
                  //   ),
                  // ),
                  // const SizedBox(width: 0),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("SKU", product['SKU'] ?? "00"),
                        buildLabelValue("Available Inventory",
                            (product['afn_total_quantity'] ?? 0)),
                        // (product['afn-fulfillable-quantity'] ?? 0) + (product['FC_Transfer'] ?? 0)),
                        buildLabelValue("Storage Cost","£ ${(product['qestimated_ais_241_270-days'] ?? 0)+(product['estimated_ais_271_300_days'] ?? 0)+(product['estimated_ais_301_330_days'] ?? 0)}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("ASIN", product['ASIN'] ?? "N/A"),
                        buildLabelValue("DOS", product['days_of_supply'] ?? '00'),
                        buildLabelValue("LTSF Cost", "£ ${product['estimated_storage_cost_next_month'] ?? '00'}"),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 30),
                const Center(
                  child: Text(
                    "Inventory Details",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.brown,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildLabelValueExpend("Warehouse Inventory", product['afn_warehouse_quantity'] ?? "00"),
                    buildLabelValueExpend("Total Sellable", product['afn_fulfillable_quantity'] ?? "00"),
                    buildLabelValueExpend("Inventory Age", (product['inv_age_0_to_30_days'] ?? "00")+(product['inv_age_31_to_60_days'] ?? "00")+(product['inv_age_61_to_90_days'] ?? "00")+(product['inv_age_91_to_180_days'] ?? "00")+(product['inv_age_181_to_270_days'] ?? "00")+(product['inv_age_271_to_365_days'] ?? "00")+(product['inv_age_365_plus_days'] ?? "00")),

                    buildLabelValueExpend("DOS", product['days_of_supply'] ?? "00"),
                    buildLabelValueExpend("Customer Reserved", product['Customer_reserved'] ?? "00"),
                    buildLabelValueExpend("FC Transfer", product['FC_Transfer'] ?? "00"),
                    buildLabelValueExpend("FC Processing", product['FC_Processing'] ?? "00"),
                    buildLabelValueExpend("Unfullfilled", product['afn_unsellable_quantity'] ?? "00"),
                    buildLabelValueExpend("Inbound Recieving", product['afn_inbound_receiving_quantity'] ?? "00"),
                  ],
                ),
                const Divider(height: 30),
                // const Center(
                //   child: Text(
                //     "Shipment Details",
                //     style: TextStyle(
                //       fontSize: 30,
                //       color: Colors.brown,
                //       fontWeight: FontWeight.w500,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                // GridView.count(
                //   shrinkWrap: true,
                //   crossAxisCount: 3,
                //   crossAxisSpacing: 1,
                //   mainAxisSpacing: 1,
                //   physics: const NeverScrollableScrollPhysics(),
                //   children: [
                //     buildLabelValueExpend("Current Inventory", product['afn-warehouse-quantity'] ?? "N/A"),
                //     buildLabelValueExpend("Current DOS", product['ASIN'] ?? "N/A"),
                //     buildLabelValueExpend("Shipment Quantity", product['ASIN'] ?? "N/A"),
                //     buildLabelValueExpend("Shipment Date", product['ASIN'] ?? "N/A"),
                //   ],
                // ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}













// // lib/screens/inventory/product_card.dart
//
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';
//
// class InventorySkuCardScreen extends StatefulWidget {
//   final Map<String, dynamic> product;
//
//   const InventorySkuCardScreen({Key? key, required this.product}) : super(key: key);
//
//   @override
//   State<InventorySkuCardScreen> createState() => _InventorySkuCardScreenState();
// }
//
// class _InventorySkuCardScreenState extends State<InventorySkuCardScreen> {
//   bool _isExpanded = false;
//
//   void _toggleExpand() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//     });
//   }
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
//   Widget buildLabelValueExpend(String label, dynamic value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xECD5B0),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(label,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//           const SizedBox(height: 8),
//           Text(value.toString(), style: const TextStyle(fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product = widget.product;
//
//     return GestureDetector(
//       onTap: _toggleExpand,
//       child: Card(
//         color: AppColors.beige,
//         margin: const EdgeInsets.all(10),
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 product['SKU']?.toString() ?? '',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//
//               Text(
//                 product['Date']?.toString() ?? '',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Flexible(
//                   //   flex: 3,
//                   //   child: Image.network(
//                   //     "https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200",
//                   //     height: 130,
//                   //     fit: BoxFit.fitHeight,
//                   //   ),
//                   // ),
//                  // const SizedBox(width: 0),
//                   Flexible(
//                     flex: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         buildLabelValue("SKU", product['SKU'] ?? "00"),
//                         buildLabelValue("Available Inventory",
//                             (product['afn-fulfillable-quantity'] ?? 0) + (product['FC_Transfer'] ?? 0)),
//                         buildLabelValue("Storage Cost", product['storage-volume'] ?? "00"),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Flexible(
//                     flex: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         buildLabelValue("ASIN", product['ASIN'] ?? "00"),
//                         buildLabelValue("DOS", product['days-of-supply'] ?? '00'),
//                         buildLabelValue("LTSF Cost", product['estimated-storage-cost-next-month'] ?? '00'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               if (_isExpanded) ...[
//                 const Divider(height: 30),
//                 const Center(
//                   child: Text(
//                     "Inventory Details",
//                     style: TextStyle(
//                       fontSize: 30,
//                       color: Colors.brown,
//                       fontWeight: FontWeight.w500,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//                 GridView.count(
//                   shrinkWrap: true,
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 3,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: [
//                     buildLabelValueExpend("Warehouse Inventory", product['afn-warehouse-quantity'] ?? "00"),
//                     buildLabelValueExpend("Total Sellable", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Inventory Age", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("DOS", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Customer Reserved", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("FC Transfer", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("FC Processing", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Unfullfilled", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Inbound Recieving", product['ASIN'] ?? "00"),
//                   ],
//                 ),
//                 const Divider(height: 30),
//                 const Center(
//                   child: Text(
//                     "Shipment Details",
//                     style: TextStyle(
//                       fontSize: 30,
//                       color: Colors.brown,
//                       fontWeight: FontWeight.w500,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//                 GridView.count(
//                   shrinkWrap: true,
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 1,
//                   mainAxisSpacing: 1,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: [
//                     buildLabelValueExpend("Current Inventory", product['afn-warehouse-quantity'] ?? "00"),
//                     buildLabelValueExpend("Current DOS", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Shipment Quantity", product['ASIN'] ?? "00"),
//                     buildLabelValueExpend("Shipment Date", product['ASIN'] ?? "00"),
//                   ],
//                 ),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

