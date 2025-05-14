class Welcome {
  final String id;
  final dynamic sku;
  final Country country;
  final int afnWarehouseQuantity;
  final int afnFulfillableQuantity;
  final int afnUnsellableQuantity;
  final int afnReservedQuantity;
  final int afnTotalQuantity;
  final int afnInboundWorkingQuantity;
  final int afnInboundShippedQuantity;
  final int afnInboundReceivingQuantity;
  final int afnResearchingQuantity;
  final int afnReservedFutureSupply;
  final int afnFutureSupplyBuyable;
  final int amazonReserved;
  final int customerReserved;
  final int fcTransfer;
  final int fcProcessing;
  final double date;
  final int v;

  Welcome({
    required this.id,
    required this.sku,
    required this.country,
    required this.afnWarehouseQuantity,
    required this.afnFulfillableQuantity,
    required this.afnUnsellableQuantity,
    required this.afnReservedQuantity,
    required this.afnTotalQuantity,
    required this.afnInboundWorkingQuantity,
    required this.afnInboundShippedQuantity,
    required this.afnInboundReceivingQuantity,
    required this.afnResearchingQuantity,
    required this.afnReservedFutureSupply,
    required this.afnFutureSupplyBuyable,
    required this.amazonReserved,
    required this.customerReserved,
    required this.fcTransfer,
    required this.fcProcessing,
    required this.date,
    required this.v,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) {
    return Welcome(
      id: json['_id'],
      sku: json['SKU'],
      country: Country.values.firstWhere(
            (e) => e.toString() == 'Country.' + json['Country'],
        orElse: () => Country.UK, // Default value if country not found
      ),
      afnWarehouseQuantity: json['afn-warehouse-quantity'],
      afnFulfillableQuantity: json['afn-fulfillable-quantity'],
      afnUnsellableQuantity: json['afn-unsellable-quantity'],
      afnReservedQuantity: json['afn-reserved-quantity'],
      afnTotalQuantity: json['afn-total-quantity'],
      afnInboundWorkingQuantity: json['afn-inbound-working-quantity'],
      afnInboundShippedQuantity: json['afn-inbound-shipped-quantity'],
      afnInboundReceivingQuantity: json['afn-inbound-receiving-quantity'],
      afnResearchingQuantity: json['afn-researching-quantity'],
      afnReservedFutureSupply: json['afn-reserved-future-supply'],
      afnFutureSupplyBuyable: json['afn-future-supply-buyable'],
      amazonReserved: json['Amazon Reserved'],
      customerReserved: json['Customer_reserved'],
      fcTransfer: json['FC_Transfer'],
      fcProcessing: json['FC_Processing'],
      date: json['Date'],
      v: json['__v'],
    );
  }
}

enum Country {
  UK
}
