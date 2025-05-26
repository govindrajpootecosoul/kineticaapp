import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final void Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
  }) : super(key: key);

  String formatFilterType(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
      case 'lastmonth':
        return 'Last Month';
      case '6months':
        return 'Last 6 Months';
      case 'last30days':
        return 'Last 30 Days';
      case 'yeartodate':
        return 'Year to Date';
      case 'monthtodate':
        return 'Current Month';

      // case 'year':
      //   return 'This Year';
      // case 'lastmonth':
      //   return 'Last Month';
      case 'custom':
        return 'Custom Range';
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 40,
      child: DropdownButtonFormField<String>(
        isDense: true,
        value: value,
        onChanged: onChanged,
        style: TextStyle(fontSize: 12, color: Colors.black),
        iconEnabledColor: Colors.black,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
        items: items.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              formatFilterType(type),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// InputDecoration customInputDecoration({String? hintText, String? labelText}) {
//   return InputDecoration(
//     contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//     hintText: hintText,
//     labelText: labelText,

//     hintStyle: TextStyle(fontSize: 12, color: Colors.black),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.black, width: 1),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.black, width: 1),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.black, width: 1),
//     ),
//     disabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.black, width: 1),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.red, width: 1),
//     ),
//     focusedErrorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(50),
//       borderSide: BorderSide(color: Colors.red, width: 1),
//     ),
//   );
// }


InputDecoration customInputDecoration({String? hintText, String? labelText}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintText: hintText,
    labelText: labelText,
    hintStyle: TextStyle(fontSize: 12, color: Colors.black),
    // filled: true,
    // fillColor: Colors.white, // Make sure background isn't transparent
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.black, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.black, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.black, width: 1),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.black, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
  );
}
