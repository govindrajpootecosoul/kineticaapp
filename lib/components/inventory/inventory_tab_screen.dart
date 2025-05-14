import 'package:flutter/material.dart';

import '../../financescreens/finance_sku.dart';
import '../../testingfiles/new_testing1.dart';
import '../profit_loss.dart';
import 'aging_screen.dart';
import 'inventory_detail.dart';
import 'inventory_executive.dart';
import 'newInventrory_main.dart';
import 'new_inventory_details.dart';
import 'new_shipment_deatils.dart';

class InventoryTabScreen extends StatelessWidget {
  final Color selectedTabColor = Color(0xFFECD5B0); // Hex: #ECD5B0

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
         // title: Text("Inventory Tabs"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: selectedTabColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: selectedTabColor,
            tabs: const [
              Tab(text: "Executive"),
              Tab(text: "SKU"),
              Tab(text: "Inventory Details"),
              Tab(text: "Shipment Details"),
              Tab(text: "Ageing"),
              // Tab(text: "P&L"),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            InventoryExecutivePage(),
            //Center(child: Text("Executive Content")),
            NewInventoryMain(),
            //NewFinanceSkuScreen(),
            //Center(child: Text("Executive Content")),
            ///InventoryDetails(),

            New_inventrory_details(),
            New_shipment_details(),
            AgingScreen_details(),

           // Testingsku(),

            //Center(child: Text("SKU Content")),
           // Center(child: Text("Inventory Details Content")),
           // Center(child: Text("Shipment Details Content")),
          ],
        ),
      ),
    );
  }
}
