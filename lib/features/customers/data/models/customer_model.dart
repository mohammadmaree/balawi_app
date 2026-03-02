/// Customer Model matching backend schema
class CustomerModel {
  String? id;
  String? fullName;
  String? phoneNumber;
  num? pantsHeight;
  num? waistWidth;
  num? pantsLegWidth;
  String? type;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.pantsHeight,
    this.waistWidth,
    this.pantsLegWidth,
    this.type,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create CustomerModel from JSON map
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id']?.toString(),
      fullName: json['fullName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      pantsHeight: json['pantsHeight'] is num
          ? json['pantsHeight']
          : (num.tryParse(json['pantsHeight']?.toString() ?? '') ?? 0),
      waistWidth: json['waistWidth'] is num
          ? json['waistWidth']
          : (num.tryParse(json['waistWidth']?.toString() ?? '') ?? 0),
      pantsLegWidth: json['pantsLegWidth'] is num
          ? json['pantsLegWidth']
          : (num.tryParse(json['pantsLegWidth']?.toString() ?? '') ?? 0),
      type: json['type']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert CustomerModel to JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'pantsHeight': pantsHeight ?? 0,
      'waistWidth': waistWidth ?? 0,
      'pantsLegWidth': pantsLegWidth ?? 0,
      'type': type ?? '',
      'notes': notes ?? '',
    };
  }

  /// Convert CustomerModel to JSON map for update requests (only non-null fields)
  Map<String, dynamic> toJsonForUpdate() {
    final Map<String, dynamic> data = {};
    if (fullName != null && fullName!.isNotEmpty) data['fullName'] = fullName;
    if (phoneNumber != null && phoneNumber!.isNotEmpty)
      data['phoneNumber'] = phoneNumber;
    if (pantsHeight != null) data['pantsHeight'] = pantsHeight;
    if (waistWidth != null) data['waistWidth'] = waistWidth;
    if (pantsLegWidth != null) data['pantsLegWidth'] = pantsLegWidth;
    if (type != null) data['type'] = type;
    if (notes != null) data['notes'] = notes;
    return data;
  }

  /// Create a copy with updated fields
  CustomerModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    num? pantsHeight,
    num? waistWidth,
    num? pantsLegWidth,
    String? type,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pantsHeight: pantsHeight ?? this.pantsHeight,
      waistWidth: waistWidth ?? this.waistWidth,
      pantsLegWidth: pantsLegWidth ?? this.pantsLegWidth,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CustomerModel(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, pantsHeight: $pantsHeight, waistWidth: $waistWidth, pantsLegWidth: $pantsLegWidth, type: $type, notes: $notes)';
  }
}
