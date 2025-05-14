import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/currency_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CommonCardComponent extends StatelessWidget {
  final String title;
  final String value;
  final String percentChange;
  final String comparedTo;
  final String? popupData;

  const CommonCardComponent({
    Key? key,
    required this.title,
    required this.value,
    this.percentChange = "",
    this.comparedTo = "",
    this.popupData,
  }) : super(key: key);

  Future<String> _loadCurrencySymbol() async {
    String symbol = await getCurrencySymbol();
    return symbol;
  }

  void _showPopup(BuildContext context) {
    if (popupData != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Details"),
            content: Text(popupData!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.beige, // Beige background
          borderRadius: BorderRadius.circular(12),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.brown,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align value to the start
                    children: [
                      FutureBuilder<String>(
                      future: _loadCurrencySymbol(),
                      builder: (context, snapshot) {
                        String formatted = formattedValue(title, value, snapshot.data ?? '');
                        return Text(
                          formatted,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.clip,
                        );
                      },
                    )
                    ],
                  ),
                ),
                /// **40% Section for Comparison**
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            percentChange,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: percentChange.contains('-')
                                  ?(checkOppositeVals(title) ? Colors.green :  Colors.red)
                                :  (checkOppositeVals(title) ? Colors.red :  Colors.green),
                            ),
                          ),
                          percentChange !=  "" ? Icon(
                            percentChange.contains('-')
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: percentChange.contains('-')
                                ? (checkOppositeVals(title) ? Colors.green :  Colors.red)
                                :  (checkOppositeVals(title) ? Colors.red :  Colors.green),
                            size: 16,
                          ) : SizedBox(width: 0),
                        ],
                      ),
                      comparedTo != "" ? Text(
                        "Compared to\n$comparedTo",
                        textAlign: TextAlign.right,
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ) : SizedBox(width: 0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

   bool checkOppositeVals(title){
    if(title.toLowerCase().contains("acos") || title.toLowerCase().contains("return")){
      return true;
    }else{
      return false;
    }
   }

String formattedValue(String title, String value, String currencySymbol) {
  if (title.contains('%')) {
    return "$value%";
  }else if(value.contains('%')){
    return value;
  }else {
      double numValue = double.parse(value);
      String val = "";
      if (numValue >= 1000000000) {
        val =  "${(numValue / 1000000000).toStringAsFixed(2)}B";
      } else if (numValue >= 1000000) {
        val =  "${(numValue / 1000000).toStringAsFixed(2)}M";
      } else if (numValue >= 10000) {
        val =  "${(numValue / 1000).toStringAsFixed(2)}K";
      } else {
        final formatter = NumberFormat("#,###.##");
        val =  formatter.format(numValue);
      }

      if (title.toLowerCase().contains('revenue') ||
          title.toLowerCase().contains('sales') ||
          title.toLowerCase().contains('spend') ||
          title.toLowerCase().contains('aov') || title.toLowerCase().contains('cpc') || title.toLowerCase().contains('price') || title.toLowerCase().contains('value')) {
        return "$currencySymbol $val";
      }
      return val;
    }
}


}