/// Statistics Model (matches GET /api/work-orders/statistics)
class StatisticsModel {
  final int total;
  final int notReady;
  final int ready;
  final int delivered;
  final int unpaid;
  final int paid;
  final num totalRevenue;
  final num totalPaidAmount;
  final num remainingAmount;

  /// Shelf number -> orders count
  final Map<String, int> ordersByShelf;

  /// Number of orders created in the last 7 days
  final int recentOrders;

  StatisticsModel({
    required this.total,
    required this.notReady,
    required this.ready,
    required this.delivered,
    required this.unpaid,
    required this.paid,
    required this.totalRevenue,
    required this.totalPaidAmount,
    required this.remainingAmount,
    required this.ordersByShelf,
    required this.recentOrders,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    // Server sends: [{ "_id": "1", "count": 3 }, ...]
    final ordersByShelf = <String, int>{};
    final shelves = json['ordersByShelf'];
    if (shelves is List) {
      for (final item in shelves) {
        if (item is Map && item['_id'] != null) {
          ordersByShelf[item['_id'].toString()] = (item['count'] as num?)?.toInt() ?? 0;
        }
      }
    }

    int toInt(dynamic value) => (value as num?)?.toInt() ?? 0;

    return StatisticsModel(
      total: toInt(json['total']),
      notReady: toInt(json['notReady']),
      ready: toInt(json['ready']),
      delivered: toInt(json['delivered']),
      unpaid: toInt(json['unpaid']),
      paid: toInt(json['paid']),
      totalRevenue: json['totalRevenue'] ?? 0,
      totalPaidAmount: json['totalPaidAmount'] ?? 0,
      remainingAmount: json['remainingAmount'] ?? 0,
      ordersByShelf: ordersByShelf,
      recentOrders: toInt(json['recentOrders']),
    );
  }
}
