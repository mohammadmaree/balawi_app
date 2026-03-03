/// Work Order Model
class WorkOrderModel {
  String? id;
  String? customerName;
  String? phoneNumber;
  String? shelfNumber;
  num? price;
  num? paidAmount;
  bool? isPaid;
  String? status;
  String? workDescription;
  String? notes;
  DateTime? deliveryDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  WorkOrderModel({
    this.id,
    this.customerName,
    this.phoneNumber,
    this.shelfNumber,
    this.price,
    this.paidAmount,
    this.isPaid,
    this.status,
    this.workDescription,
    this.notes,
    this.deliveryDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Create WorkOrderModel from JSON map
  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['_id']?.toString(),
      customerName: json['customerName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      shelfNumber: json['shelfNumber']?.toString(),
      price: json['price'] is num
          ? json['price']
          : (num.tryParse(json['price']?.toString() ?? '') ?? 0),
      paidAmount: json['paidAmount'] is num
          ? json['paidAmount']
          : (num.tryParse(json['paidAmount']?.toString() ?? '') ?? 0),
      isPaid: json['isPaid'] ?? false,
      status: json['status']?.toString() ?? 'جاهز',
      workDescription: json['workDescription']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert WorkOrderModel to JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'shelfNumber': shelfNumber,
      'price': price ?? 0,
      'paidAmount': paidAmount ?? 0,
      'isPaid': isPaid ?? false,
      'status': status ?? 'جاهز',
      'workDescription': workDescription ?? '',
      'notes': notes ?? '',
    };
  }

  /// Convert WorkOrderModel to JSON map for update requests
  Map<String, dynamic> toJsonForUpdate() {
    final Map<String, dynamic> data = {};
    if (customerName != null && customerName!.isNotEmpty) {
      data['customerName'] = customerName;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['phoneNumber'] = phoneNumber;
    }
    if (shelfNumber != null) data['shelfNumber'] = shelfNumber;
    if (price != null) data['price'] = price;
    if (paidAmount != null) data['paidAmount'] = paidAmount;
    if (isPaid != null) data['isPaid'] = isPaid;
    if (status != null) data['status'] = status;
    if (workDescription != null) data['workDescription'] = workDescription;
    if (notes != null) data['notes'] = notes;
    return data;
  }

  /// Get remaining amount
  num get remainingAmount {
    return (price ?? 0) - (paidAmount ?? 0);
  }

  /// Check if fully paid
  bool get isFullyPaid {
    return remainingAmount <= 0;
  }

  @override
  String toString() {
    return 'WorkOrderModel(id: $id, customerName: $customerName, shelfNumber: $shelfNumber, price: $price, status: $status)';
  }
}
