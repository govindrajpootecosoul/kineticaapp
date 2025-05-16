class ApiConfig {
  static const String baseUrl = "https://api.thrivebrands.ai/api";
//https://api.thrivebrands.ai
  static const String _baseUrllocal = "http://192.168.50.92:2000/api";
  static const String localdata="$_baseUrllocal/data";

  static const String salesSku = "$baseUrl/sales-sku-get";
  static const String pnlData = "$baseUrl/pnl-data";
  //https://api.thrivebrands.ai/api/pnl-data
  static const String ukInventory = "$baseUrl/ukinventory-data";
}
