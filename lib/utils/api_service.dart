import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static  String baseUrl = "http://localhost:3000";

  static Future<Map<String, dynamic>> fetchAnalytics(
      {required String provider,
      required String models,
      required String region,
      required String dateRange,
      required String granularity,
      required String timeParameter,
      String? asin}) async {
    List<dynamic> countriesMap = [
      {"name": "United States", "code": "us"},
      {"name": "Canada", "code": "ca"},
      {"name": "India", "code": "in"},
      {"name": "Australia", "code": "au"},
      {"name": "United Kingdom", "code": "gb"},
    ];
    try {
      String encodedDateRange =
          Uri.encodeComponent(dateRange);
      String url = "https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/analytics/all?"
          "provider=AMAZON&models=$models&region=IN&date_range=$encodedDateRange&granularity=$granularity&timeParameter=$timeParameter";
      // String url = "http://localhost:3000/analytics/all?"
      //     "provider=AMAZON&models=$models&region=IN&date_range=$encodedDateRange&granularity=$granularity&timeParameter=$timeParameter";
      print("Print Live url :::: ${url}");
          if (asin != null && asin.isNotEmpty) {
            url += "&asin=$asin";
          }
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedRegion =
          prefs.getString('region') ?? "";

      Map<String, dynamic>? country = countriesMap.firstWhere(
        (c) => c["name"] == selectedRegion,
        orElse: () => {"name": "Default", "code": "us"}, // Default value
      );
      var response = await http.get(Uri.parse(url),
          headers: {"Content-Type": "application/json", "x-region": country?["code"]});

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Convert JSON to Map
      } else {
        throw Exception("Failed to fetch data: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      return {"error": e.toString()};
    }
  }

  static String fetchGranularity(String selectedTime) {
    if (selectedTime == "Today" || selectedTime == "Yesterday") {
      return "Day";
    } else if (selectedTime == "Week" || selectedTime == "Last 30 days") {
      return "Week";
    } else if (selectedTime == "Month") {
      return "Month";
    } else if (selectedTime == "Year") {
      return "Year";
    } else if (selectedTime == "Last Week" ||
        selectedTime == "Last Month" ||
        selectedTime == "This Month") {
      return "Day";
    } else if (selectedTime == "Last Year" ||
        selectedTime == "Last 6 months" ||
        selectedTime == "Last 12 months") {
      return "Month";
    } else {
      return "Day";
    }
  }
}
