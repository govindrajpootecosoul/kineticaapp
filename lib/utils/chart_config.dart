Map<String, dynamic> getChartConfig(String filterType) {
  final now = DateTime.now();
  int activeCount = 0;
  List<String> labels = [];
//  "lastmonth",
//     "monthtodate",
//     "previousyear",
//     "currentyear",
//     "custom"
  switch (filterType) {
    case 'monthtodate':
      int totalDays = DateTime(now.year, now.month + 1, 0).day;
      activeCount = now.day;
      labels = List.generate(totalDays, (i) => '${i + 1}');
      break;

    case 'lastmonth':
      DateTime lastMonth = DateTime(now.year, now.month - 1);
      int totalDays = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
      activeCount = totalDays;
      labels = List.generate(totalDays, (i) => '${i + 1}');
      break;

  // case 'currentyear':
    case 'yeartodate':
      activeCount = now.month;
      labels = List.generate(12, (i) => getMonthAbbr(i + 1));
      break;

    case 'previousyear':
      activeCount = 12;
      labels = List.generate(12, (i) => getMonthAbbr(i + 1));
      break;

    default:
    // fallback to current month
      int totalDays = DateTime(now.year, now.month + 1, 0).day;
      activeCount = now.day;
      labels = List.generate(totalDays, (i) => '${i + 1}');
  }

  return {
    'activeCount': activeCount,
    'labels': labels,
  };
}

String getMonthAbbr(int month) {
  const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return monthNames[month - 1];
}



