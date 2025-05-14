class ApiConfig {
  static const String _baseUrl = "https://api.thrivebrands.ai/api";

  static const String _baseUrllocal = "http://192.168.50.92:2000/api";
  static const String localdata="$_baseUrllocal/data";

  static const String salesSku = "$_baseUrl/sales-sku-get";
  static const String pnlData = "$_baseUrl/pnl-data";
  static const String ukInventory = "$_baseUrl/ukinventory-data";
}
