import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/inventory/inventory_detail.dart';
import 'package:flutter_application_1/components/inventory/inventory_executive.dart';
import 'package:flutter_application_1/components/inventory/inventory_shipment.dart';
import 'package:flutter_application_1/components/inventory/inventory_sku.dart';
import 'package:flutter_application_1/components/sales/sales.dart';
import 'package:flutter_application_1/components/sales/sales_sku.dart';
import 'package:flutter_application_1/components/sales/salessku_details.dart';
import 'package:flutter_application_1/utils/colors.dart';

class InventoryMainPage extends StatefulWidget {
  @override
  _InventoryMainPageState createState() => _InventoryMainPageState();
}

class _InventoryMainPageState extends State<InventoryMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSelected = false;

  void onButtonPressed(){
    setState(() {
      isSelected = !isSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40), 
        child:  AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.1), // Light shadow color
                      spreadRadius: 2, // Spread of shadow
                      blurRadius: 4, // Blur effect
                      offset: Offset(
                          0, 2), // Position of shadow (horizontal, vertical)
                    ),
                  ],
                ),
              child: TabBar(
              indicator: BoxDecoration(
                color: AppColors.cream,
                border: null,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown),
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              controller: _tabController,
              tabs: [
                // Tab(text: "Executive"),
                Tab(text: "SKU"),
                // Tab(text: "Inventory Detail"),
                // Tab(text: "Shipment Detail"),
              ],
            ))
          ],
        ),
        
      )),
      body: TabBarView(
        controller: _tabController,
        children: [
          // InventoryExecutivePage(), // Replace with actual widget
          isSelected ? SalesskuDetails(onButtonPressed: onButtonPressed, productData: {},) : InventorySkuPage(onButtonPressed: onButtonPressed),
        // InventoryDetails(),
        // Inventoryshipmentdetails()
        ],
      ),
    );
  }
}

class BikePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Coming Soon"));
  }
}
