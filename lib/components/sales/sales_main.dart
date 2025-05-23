import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/sales/sales.dart';
import 'package:flutter_application_1/components/sales/sales_sku.dart';
import 'package:flutter_application_1/components/sales/salessku_details.dart';
import 'package:flutter_application_1/utils/colors.dart';

import '../../financescreens/finance_sku.dart';
import 'filterscreen/SKU_filterscreen.dart';
import 'filterscreen/new_Sales_Executive_Screen.dart';
import 'filterscreen/regindata.dart';
import 'filterscreen/reginwise.dart';
import 'new_sales_sku_screen.dart';

class SalesMainPage extends StatefulWidget {
  @override
  _SalesMainPageState createState() => _SalesMainPageState();
}

class _SalesMainPageState extends State<SalesMainPage>
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
    _tabController = TabController(length: 3, vsync: this);
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
                Tab(text: "Executive"),
                Tab(text: "SKU"),
                Tab(text: "Region"),
              ],
            ))
          ],
        ),
        
      )),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewSalesExecutiveScreen(),
          //SalesPage(), // Replace with actual widget
        //  isSelected ? SalesskuDetails(onButtonPressed: onButtonPressed, productData: {},) : SalesSkuPage(onButtonPressed: onButtonPressed),
          isSelected ? SalesskuDetails(onButtonPressed: onButtonPressed, productData: {},) : Filter_SalesSkuScreen(),
          Filter_SalesRereginwiseScreen(),

          //SalesApp(),
        // BikePage(),
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
