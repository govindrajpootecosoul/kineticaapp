import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Product {
  final String productName;
  final String sku;
  final String asin;
  final String imageUrl;
  final int warehouseInventory;
  final int totalSellable;
  final int dos;
  final int unfulfilled;

  Product({
    required this.productName,
    required this.sku,
    required this.asin,
    required this.imageUrl,
    required this.warehouseInventory,
    required this.totalSellable,
    required this.dos,
    required this.unfulfilled,
  });

  // Parsing JSON response
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json["productName"],
      sku: json["sku"],
      asin: json["asin"],
      imageUrl: json["imageUrl"],
      warehouseInventory: json["warehouseInventory"],
      totalSellable: json["totalSellable"],
      dos: json["dos"],
      unfulfilled: json["unfulfilled"],
    );
  }
}

class Inventoryshipmentdetails extends StatefulWidget {
  @override
  _InventoryshipmentdetailsState createState() => _InventoryshipmentdetailsState();
}

class _InventoryshipmentdetailsState extends State<Inventoryshipmentdetails> {
  late Future<List<Product>> _futureProducts;
  String _selectedChannel = "Amazon";
  String _selectedTime = "Last 12 months";
 List<String> _selectedItems = []; // Stores selected values
  final List<String> _options = ["Warehouse INV.", "Total Sellable", "Inventory Age", "DOS", "Customer Reserved", "FC Transfer", "FC Processing", "Unfulfilled", "Inbound Recieving"];
  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  // Simulating an API call
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay
    List<Map<String, dynamic>> jsonData = [
      {
        "productName": "Kinetica Whey Protein Powder | 4.5kg",
        "sku": "BS140MM100",
        "asin": "BOCDWJJ8CK",
        "imageUrl": "https://your-image-url.com",
        "warehouseInventory": 120,
        "totalSellable": 80,
        "dos": 15,
        "unfulfilled": 5,
      },
      {
        "productName": "Optimum Nutrition Gold Standard Whey | 2kg",
        "sku": "ONWHEY2KG",
        "asin": "BOCXYZ123",
        "imageUrl": "https://your-image-url.com",
        "warehouseInventory": 200,
        "totalSellable": 180,
        "dos": 25,
        "unfulfilled": 10,
      },
      {
        "productName": "MuscleTech NitroTech Whey Protein | 1.8kg",
        "sku": "MTNITRO180",
        "asin": "BOCWHEY789",
        "imageUrl": "https://your-image-url.com",
        "warehouseInventory": 90,
        "totalSellable": 70,
        "dos": 10,
        "unfulfilled": 8,
      },
    ];
    return jsonData.map((data) => Product.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loader while fetching data
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading products"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No products found"));
          }

          List<Product> products = snapshot.data!;

          return Column(
            children: [
              // Dropdown Filters
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDropdown("Channel", ["Amazon", "eBay", "Shopify"], _selectedChannel, (newValue) {
                      setState(() {
                        _selectedChannel = newValue!;
                      });
                    }),
                    _buildDropdown(
                      "Select Time Range",
                      ["Today", "This week", "Last 30 days", "Last 6 months", "Last 12 months"],
                      _selectedTime,
                      (newValue) {
                        setState(() {
                          _selectedTime = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),

Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () async {
              final List<String>? selectedValues = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MultiSelectDialog(
                    options: _options,
                    selectedValues: _selectedItems,
                  );
                },
              );
              if (selectedValues != null) {
                setState(() {
                  _selectedItems = selectedValues;
                });
              }
            },
            child:Align(alignment: Alignment.centerRight,
           child: Container(
              width: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _selectedItems.isEmpty
                          ? "Filter"
                          : _selectedItems.join(", "), // Display selected items
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            )),
          ),
        ),
              // Product List
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.beige, // Beige background
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image (Use network image)
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8),
            //   child: Image.asset(
            //     'assets/product_image.jpg',
            //     width: 80,
            //     height: 80,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 80),
            //   ),
            // ),
            SizedBox(width: 12),

            // Product Info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow("SKU", product.sku.toUpperCase()),
                  _buildInfoRow("ASIN", product.asin.toUpperCase()),
                ],
              ),
            ),

            // Inventory Details (Scrollable)
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInventoryColumn("Current\nInventory", product.warehouseInventory),
                    _buildInventoryColumn("Current\nDos", product.totalSellable),
                    _buildInventoryColumn("Shipment\nQuantity", product.dos),
                    _buildInventoryColumn("Shipment\nDate", product.unfulfilled),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildInventoryColumn(String title, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 50, // Fixed width for alignment
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gold, // Background color for title
            borderRadius: BorderRadius.circular(0),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 3), // Space between title and value
        Container(
          width: 80, // Matching width
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cream,
          // Background color for value
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value.toString().padLeft(4, '0'), // Formatting numbers like "0000"
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

}

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedValues;

  MultiSelectDialog({required this.options, required this.selectedValues});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedValues;

  @override
  void initState() {
    super.initState();
    _tempSelectedValues = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      alignment: Alignment.centerRight,
      backgroundColor: AppColors.filterbg,
      title: Text("Filters",style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold,fontSize: 19),),
      content: SingleChildScrollView(
        child: Column(
          children: widget.options.map((option) {
            return Column(
              children: [
                CheckboxListTile(
                  selectedTileColor: AppColors.primaryBlue,
                  checkColor: Colors.transparent,
                  title: Text(option,style: TextStyle(color: AppColors.primaryBlue),),
                  value: _tempSelectedValues.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelectedValues.add(option);
                      } else {
                        _tempSelectedValues.remove(option);
                      }
                    });
                  },
                ),
                Divider(
                  color: Colors.black, // Black border
                  thickness: 1, // Thickness of the border
                  height: 1, // Space between divider and list item
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, widget.selectedValues), // Cancel without saving
          child: Text("Cancel",style: TextStyle(color: Colors.black),),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context, _tempSelectedValues), // Save selected values
          child: Container(
            padding: EdgeInsets.all(15),
            width: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: AppColors.beige),
            child:  Text("Apply"),
        )),
      ],
    );
  }
}