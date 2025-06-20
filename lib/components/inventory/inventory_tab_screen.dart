// import 'package:flutter/material.dart';

// import '../../financescreens/finance_sku.dart';
// import '../../graph/barchart.dart';
// import '../../testingfiles/new_testing1.dart';
// import '../../utils/colors.dart';
// import '../profit_loss.dart';
// import 'aging_screen.dart';
// import 'inventory_detail.dart';
// import 'inventory_executive.dart';
// import 'inventory_graph/product_category.dart';
// import 'newInventrory_main.dart';
// import 'new_inventory_details.dart';
// import 'new_shipment_deatils.dart';

// class InventoryTabScreen extends StatefulWidget {
//   @override
//   State<InventoryTabScreen> createState() => _InventoryTabScreenState();
// }

// class _InventoryTabScreenState extends State<InventoryTabScreen> with SingleTickerProviderStateMixin{
//   final Color selectedTabColor = Color(0xFFECD5B0);
//  // Hex: #ECD5B0
//   late TabController _tabController;

//   final List<Tab> myTabs = const [
//     Tab(text: 'Executive'),
//     Tab(text: 'SKU'),
//     Tab(text: 'Inventory Details'),
//     Tab(text: 'Ageing'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: myTabs.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       appBar: AppBar(
//         toolbarHeight: 0, // Removes extra space above TabBar
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child:
//           TabBar(
//             controller: _tabController,
//             tabs: myTabs,
//             indicatorSize: TabBarIndicatorSize.tab,
//             tabAlignment: TabAlignment.fill,
//             indicator: BoxDecoration(
//               color: AppColors.gold,
//             ),
//             indicatorColor: Colors.black,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.black,
//           ),
//         ),
//       ),
//       body:  TabBarView(
//         controller: _tabController,
//         children: [
//           InventoryExecutivePage(),
//           //Center(child: Text("Executive Content")),


//            NewInventoryMain(),
//           //InventoryScreen(),

//           //NewFinanceSkuScreen(),
//           //Center(child: Text("Executive Content")),
//           ///InventoryDetails(),
//           //BarChartSample4(),
//           New_inventrory_details(),
//           //New_shipment_details(),
//           AgingScreen_details(),

//          // Testingsku(),

//           //Center(child: Text("SKU Content")),
//          // Center(child: Text("Inventory Details Content")),
//          // Center(child: Text("Shipment Details Content")),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart'; // for routeObserver
import '../../utils/colors.dart';
import 'aging_screen.dart';
import 'inventory_executive.dart';
import 'newInventrory_main.dart';
import 'new_inventory_details.dart';

class InventoryTabScreen extends StatefulWidget {
  @override
  State<InventoryTabScreen> createState() => _InventoryTabScreenState();
}

class _InventoryTabScreenState extends State<InventoryTabScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Executive'),
    Tab(text: 'SKU'),
    Tab(text: 'Inventory Details'),
    Tab(text: 'Ageing'),
  ];

  bool _dialogShown = false;
  bool isWideScreen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _showInventoryInfoPopupOnce();
  }

  @override
  void didPopNext() {
    _showInventoryInfoPopupOnce();
  }

  void _showInventoryInfoPopupOnce() {
    if (!_dialogShown) {
      _dialogShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                width: isWideScreen && kIsWeb ? 600 : null,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          "Inventory Update Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildBulletText("Amazon Inventory data is as of Today - 1"),
                    _buildBulletText("Ageing data is as of Today - 2"),
                    _buildBulletText("Instock and Days in stock are as of Today - 3"),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Ok",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      });
    }
  }
  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: myTabs,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: AppColors.gold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InventoryExecutivePage(),
          NewInventoryMain(),
          New_inventrory_details(),
          AgingScreen_details(),
        ],
      ),
    );
  }
}

 