import 'package:flutter/material.dart';

import '../../financescreens/finance_sku.dart';
import '../../graph/barchart.dart';
import '../../testingfiles/new_testing1.dart';
import '../../utils/colors.dart';
import '../profit_loss.dart';
import 'aging_screen.dart';
import 'inventory_detail.dart';
import 'inventory_executive.dart';
import 'newInventrory_main.dart';
import 'new_inventory_details.dart';
import 'new_shipment_deatils.dart';

class InventoryTabScreen extends StatefulWidget {
  @override
  State<InventoryTabScreen> createState() => _InventoryTabScreenState();
}

class _InventoryTabScreenState extends State<InventoryTabScreen> with SingleTickerProviderStateMixin{
  final Color selectedTabColor = Color(0xFFECD5B0);
 // Hex: #ECD5B0
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Executive'),
    Tab(text: 'SKU'),
    Tab(text: 'Inventory Details'),
    Tab(text: 'Ageing'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        toolbarHeight: 0, // Removes extra space above TabBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child:
          TabBar(
            controller: _tabController,
            tabs: myTabs,
            indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.fill,
            indicator: BoxDecoration(
              color: AppColors.gold,
            ),
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
          ),
        ),
      ),
      body:  TabBarView(
        controller: _tabController,
        children: [
          InventoryExecutivePage(),
          //Center(child: Text("Executive Content")),
          NewInventoryMain(),
          //NewFinanceSkuScreen(),
          //Center(child: Text("Executive Content")),
          ///InventoryDetails(),
          //BarChartSample4(),
          New_inventrory_details(),
          //New_shipment_details(),
          AgingScreen_details(),

         // Testingsku(),

          //Center(child: Text("SKU Content")),
         // Center(child: Text("Inventory Details Content")),
         // Center(child: Text("Shipment Details Content")),
        ],
      ),
    );
  }
}