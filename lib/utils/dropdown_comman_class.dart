

import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;

  const SearchableDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late List<String> filteredItems;
  late TextEditingController controller;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    filteredItems = widget.items;
  }

  void _filter(String query) {
    setState(() {
      filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _select(String value) {
    widget.onChanged(value);
    controller.clear();
    _filter('');
    setState(() {
      isDropdownOpen = false;
    });
  }

  void _clear() {
    widget.onChanged(null);
    controller.clear();
    _filter('');
    setState(() {
      isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              margin: EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedValue ?? widget.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.selectedValue == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),

          if (isDropdownOpen) ...[
            TextField(
              controller: controller,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: "Search ${widget.label}",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            SizedBox(height: 4),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListView.builder(
                itemCount: filteredItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text("Clear", style: TextStyle(color: Colors.red)),
                      onTap: _clear,
                    );
                  }
                  final item = filteredItems[index - 1];
                  return ListTile(
                      title: Text(item),
                      onTap: () =>{ _select(item),
                        print("print selected items:::: ${item}")
                      }

                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
