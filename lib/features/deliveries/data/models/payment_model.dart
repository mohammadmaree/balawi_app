/// One payment on a work order
class PaymentModel {
  final String? id;
  final num amount;
  final DateTime? paidAt;
  final String note;

  PaymentModel({this.id, required this.amount, this.paidAt, this.note = ''});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id']?.toString(),
      amount: json['amount'] is num
          ? json['amount']
          : (num.tryParse(json['amount']?.toString() ?? '') ?? 0),
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString())?.toLocal()
          : null,
      note: json['note']?.toString() ?? '',
    );
  }
}
