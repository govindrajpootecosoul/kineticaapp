import 'package:shared_preferences/shared_preferences.dart';

/// List of supported regions with names and currency symbols.
final List<Map<String, String>> regionList = [
  {"name": "United States", "code": "us", "symbol": "\$"},
  {"name": "Canada", "code": "ca", "symbol": "C\$"},
  {"name": "India", "code": "in", "symbol": "₹"},
  {"name": "Australia", "code": "au", "symbol": "A\$"},
  {"name": "United Kingdom", "code": "gb", "symbol": "£"},
];

/// Retrieves the saved region code from SharedPreferences.
Future<String?> getRegion() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('region');
}

Future<String> getCurrencySymbol() async {
  String? regionCode = await getRegion();
  print(regionCode);
  final region = regionList.firstWhere(
    (r) => r["name"] == regionCode,
    orElse: () => {"symbol": "\$"},
  );
  return region["symbol"]!;
}
String getRegionName(String? regionCode) {
  final region = regionList.firstWhere(
    (r) => r["code"] == regionCode?.toLowerCase(),
    orElse: () => {"name": "United States"}, // Default to US
  );
  return region["name"]!;
}
