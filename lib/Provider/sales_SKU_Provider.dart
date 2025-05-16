// lib/providers/sales_sku_provider.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../utils/ApiConfig.dart';

class SalesSkuProvider with ChangeNotifier {
  List<dynamic> _inventoryList = [];
  bool _isLoading = false;
  String _error = '';

  List<dynamic> get inventoryList => _inventoryList;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      var dio = Dio();
      var response = await dio.get(ApiConfig.ukInventory);

      if (response.statusCode == 200) {
        _inventoryList = response.data;
      } else {
        _error = 'Error: ${response.statusMessage}';
      }
    } catch (e) {
      _error = 'Exception: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


class InventoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> inventoryList = [];
  List<String> skuList = [];
  String error = '';
  bool isLoading = false;

  Future<void> fetchAllInventory() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/inventory'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        inventoryList = data.cast<Map<String, dynamic>>();
      } else {
        error = 'Failed to load inventory';
      }
    } catch (e) {
      error = 'Error fetching inventory: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInventoryBySku(String sku) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/inventory?sku=$sku'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        inventoryList = data.cast<Map<String, dynamic>>();
      } else {
        error = 'Inventory not found';
      }
    } catch (e) {
      error = 'Error fetching inventory: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSKUs() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku?q='));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        skuList = data.cast<String>();
      } else {
        error = 'Failed to load SKUs';
      }
    } catch (e) {
      error = 'Error fetching SKUs: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


//
// class InventoryProvider with ChangeNotifier {
//   List<dynamic> _inventoryList = [];
//   bool _isLoading = true;
//   String _error = '';
//
//   List<dynamic> get inventoryList => _inventoryList;
//   bool get isLoading => _isLoading;
//   String get error => _error;
//
//   Future<void> fetchProducts() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       var dio = Dio();
//       var response = await dio.get(ApiConfig.ukInventory);
//
//       if (response.statusCode == 200) {
//         _inventoryList = response.data;
//         _error = '';
//       } else {
//         _error = 'Error: ${response.statusMessage}';
//       }
//     } catch (e) {
//       _error = 'Exception: $e';
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
// }


