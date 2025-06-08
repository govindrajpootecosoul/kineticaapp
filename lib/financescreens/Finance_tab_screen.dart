import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'Finance_Executive_Screen.dart';
import 'finance_sku.dart';
import 'newfinancescreen.dart';

class FinanceTabScreen extends StatefulWidget {
  const FinanceTabScreen({super.key});

  @override
  State<FinanceTabScreen> createState() => _FinanceTabScreenState();
}

class _FinanceTabScreenState extends State<FinanceTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Executive'),
    Tab(text: 'SKU'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
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
      body: TabBarView(
        controller: _tabController,
        children:  [
          //PnlDataScreen(),
          FinanceExecutiveScreen(productval:"0",),
          NewFinanceSkuScreen(financeval:"0"),

        ],
      ),
    );
  }
}
