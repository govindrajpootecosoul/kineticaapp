import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketingAdgroupPage extends StatefulWidget {
  @override
  _MarketingAdgroupPageState createState() => _MarketingAdgroupPageState();
}

class _MarketingAdgroupPageState extends State<MarketingAdgroupPage> {
  String _selectedUnits = "Units Sold";
  String _selectedChannel = "Amazon";
  String _selectedTime = "Month to date";

  final List<Map<String, String>> campaigns = List.generate(
    5, // Number of campaigns
    (index) => {
      "campaignName": "Ad Group ${index + 1}",
      "campaignType": "Search Ads",
      "campaignStatus": "Active",
      "adSpend": "\$500",
      "adSales": "\$1200",
      "acos": "20%",
      "budget": "\$800"
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown Filters
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDropdown(
                "Channel",
                ["Amazon", "eBay", "Shopify"],
                _selectedChannel,
                (newValue) {
                  setState(() {
                    _selectedChannel = newValue!;
                  });
                },
              ),
              _buildDropdown(
                "Select Time Range",
                [
                  "Today",
                  "This week",
                  "Last 30 days",
                  "Last 6 months",
                  "Last 12 months",
                  "Month to date",
                  "Year to date",
                  "Custom"
                ],
                _selectedTime,
                (newValue) {
                  setState(() {
                    _selectedTime = newValue!;
                    if (_selectedTime == 'Custom') {
                      _showDateRangePicker(context);
                    } else {
                      String range = _getDateRange(_selectedTime);
                      _fetchData(range);
                    }
                  });
                },
              ),
            ],
          ),
        ),

        // Campaign List
        Expanded(
          child: ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              return CampaignCard(campaign: campaigns[index]);
            },
          ),
        ),
      ],
    );
  }

  // Helper function for dropdowns
  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      style: GoogleFonts.montserrat(
          color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Dummy function to show Date Picker
  void _showDateRangePicker(BuildContext context) {
    // Implement Date Picker logic here
  }

  // Dummy function to simulate fetching data
  String _getDateRange(String timeRange) {
    // Simulate getting date range based on selected time
    return "Date range for $timeRange";
  }

  void _fetchData(String range) {
    // Simulate fetching data based on range
  }
}

class CampaignCard extends StatelessWidget {
  final Map<String, String> campaign;

  const CampaignCard({Key? key, required this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.beige,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Name
            Text(
              campaign["campaignName"]!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.gold),
            ),
            const SizedBox(height: 8),

            // Campaign Type & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo("Campaign Type", campaign["campaignType"]!),
                _buildInfo("Campaign Status", campaign["campaignStatus"]!),
              ],
            ),
            const SizedBox(height: 8),

            // Ad Spend & Ad Sales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo("Ad Spend", campaign["adSpend"]!),
                _buildInfo("Ad Sales", campaign["adSales"]!),
              ],
            ),
            const SizedBox(height: 8),

            // ACOS & Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo("ACOS", campaign["acos"]!),
                _buildInfo("Budget", campaign["budget"]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
