import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/inventory/inventory_executive.dart';
import 'package:flutter_application_1/components/inventory/inventory_shipment.dart';
import 'package:flutter_application_1/components/inventory/inventory_sku.dart';
import 'package:flutter_application_1/components/marketing/marketing_adgroup.dart';
import 'package:flutter_application_1/components/marketing/marketing_campaign.dart';
import 'package:flutter_application_1/components/marketing/marketing_executive.dart';
import 'package:flutter_application_1/components/sales/sales.dart';
import 'package:flutter_application_1/components/sales/sales_sku.dart';
import 'package:flutter_application_1/components/sales/salessku_details.dart';
import 'package:flutter_application_1/utils/colors.dart';

class MarketingMainPage extends StatefulWidget {
  @override
  _MarketingMainPageState createState() => _MarketingMainPageState();
}

class _MarketingMainPageState extends State<MarketingMainPage>
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
    _tabController = TabController(length: 4, vsync: this);
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
                Tab(text: "Campaign"),
                // Tab(text: "SKU"),
                // Tab(text: "Campaign"),
                Tab(text: "Ad Group",),
                Tab(text: "Targeting",)
              ],
            ))
          ],
        ),
        
      )),
      body: TabBarView(
        controller: _tabController,
        children: [
          MarketingExecutivePage(),
          MarketingCampaignPage(),
          // BikePage(),
          MarketingAdgroupPage(),
          BikePage(),

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
