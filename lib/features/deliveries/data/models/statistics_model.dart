import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';

/// Statistics Model
class StatisticsModel {
  final int total;
  final int ready;
  final int delivered;
  final int unpaid;
  final int paid;
  final num totalRevenue;
  final num totalPaidAmount;
  final num remainingAmount;
  final Map<String, int> ordersByShelf;
  final List<WorkOrderModel> recentOrders;

  StatisticsModel({
    required this.total,
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
    final ordersByShelf = <String, int>{};
    if (json['ordersByShelf'] != null) {
      (json['ordersByShelf'] as Map<String, dynamic>).forEach((key, value) {
        ordersByShelf[key] = value as int;
      });
    }

    final recentOrders = <WorkOrderModel>[];
    if (json['recentOrders'] != null) {
      recentOrders.addAll(
        (json['recentOrders'] as List)
            .map((e) => WorkOrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return StatisticsModel(
      total: json['total'] ?? 0,
      ready: json['ready'] ?? 0,
      delivered: json['delivered'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
      paid: json['paid'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
      totalPaidAmount: json['totalPaidAmount'] ?? 0,
      remainingAmount: json['remainingAmount'] ?? 0,
      ordersByShelf: ordersByShelf,
      recentOrders: recentOrders,
    );
  }
}
