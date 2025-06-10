class ApiConfig {
  static const String baseUrl = "https://api.thrivebrands.ai/api";
//https://api.thrivebrands.ai
  static const String baseUrllocal = "http://192.168.18.131:3000/api";
  static const String localdata="$baseUrllocal/data";

  static const String salesSku = "$baseUrl/sales-sku-get";
  static const String pnlData = "$baseUrl/pnl-data";
  //https://api.thrivebrands.ai/api/pnl-data
  static const String ukInventory = "$baseUrl/ukinventory-data";
}
//http://localhost:3000/api/data/filterData?range=lastmonth