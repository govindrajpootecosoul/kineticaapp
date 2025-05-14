class DataMapping {
  static String getComparativePeriod(String period) {
  switch (period) {
    case "Today":
      return "Yesterday";
    case "This week":
      return "Last week";
    case "Last 30 days":
      return "Previous 30 days";
    case "Last 6 months":
      return "Previous 6 months";
    case "Last 12 months":
      return "Previous 12 months";
    case "Month to date":
      return "last month";
    case "Year to date":
      return "last year";
    default:
      return "Unknown period";
  }
  }

  static List<Map<String, dynamic>> formatApiResponse(
      Map<String, dynamic> apiResponse, Map<String, String> fieldMapping, String comparedTo) {
    List<Map<String, dynamic>> formattedData = [];

    fieldMapping.forEach((key, title) {
      if (apiResponse.containsKey(key)) {
        dynamic value = apiResponse[key];

        // Handle nested objects (like totalSales.amount)
        if (value is Map<String, dynamic> && value.containsKey("amount")) {
          value = value["amount"];
        }

        // Convert large numbers to L (Lakhs)
        if (value is num && value > 100000) {
          value = "${(value).toStringAsFixed(2)}";
        } else {
          value = value.toString();
        }

        formattedData.add({
          "title": title,
          "value": value,
          "percentChange": "3%", // Hardcoded
          "comparedTo": getComparativePeriod(comparedTo)  // Hardcoded
        });
      }
    });

    return formattedData;
  }

  static List<Map<String, dynamic>> getNestedValue(Map<String, dynamic> data, Map<String, String> uiFields) {
       List<Map<String, String>> uiData = [];

  String getNestedValue(Map<String, dynamic> data, String path) {
    List<String> keys = path.split('.');
    dynamic value = data;

    for (String key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return "N/A"; // Return default if key not found
      }
    }
    return value.toString();
  }

  uiFields.forEach((key, title) {
    String value = getNestedValue(data, key);
    uiData.add({
      "title": title,
      "value": value.isNotEmpty ? value : "N/A",
      "percentChange": "3%", // Hardcoded
      "comparedTo": "Yesterday", // Hardcoded
    });
  });

  return uiData;
}

}
