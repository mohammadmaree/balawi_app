class AppConstants {
  // General
  static const String TAJAWAL = 'Tajawal';

  // Security
  static const String defaultPin = '0000';

  // Customer Types
  static const String typeNormal = 'عادي';
  static const String typeLebanese = 'لبناني';
  static const List<String> customerTypes = [typeNormal, typeLebanese];

  // Shelf Numbers
  static const List<String> shelfNumbers = ['1', '2', '3', '4', 'ارض', 'طاولة'];

  // Work Order Status
  static const String statusReady = 'جاهز';
  static const String statusDelivered = 'تم التسليم';
  static const List<String> workOrderStatuses = [statusReady, statusDelivered];
}
