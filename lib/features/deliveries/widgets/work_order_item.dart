import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';
import 'package:balawi_app/features/deliveries/pages/work_order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WorkOrderItem extends StatelessWidget {
  final WorkOrderModel workOrder;
  final VoidCallback? onDelete;

  const WorkOrderItem({super.key, required this.workOrder, this.onDelete});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    //return DateFormat('dd/MM/yyyy HH:mm').format(date);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: PrimaryColors.danger,
                    size: UiResponsive.screenWidth! * 0.07,
                  ),
                  SizedBox(width: UiResponsive.calculateWidth(10)),
                  BuildDefaultText(
                    text: LanguageKeys.deleteConfirmationTitle,
                    color: PrimaryColors.black,
                    fontSize: UiResponsive.dimension_18,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildDefaultText(
                    text: LanguageKeys.deleteConfirmationMessage,
                    color: PrimaryColors.black,
                    fontSize: UiResponsive.dimension_14,
                  ),
                  SizedBox(height: UiResponsive.calculateHeight(8)),
                  BuildDefaultText(
                    text: workOrder.customerName ?? '',
                    color: PrimaryColors.black,
                    fontSize: UiResponsive.dimension_16,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: UiResponsive.calculateHeight(12)),
                  BuildDefaultText(
                    text: LanguageKeys.cannotUndoAction,
                    color: PrimaryColors.error,
                    fontSize: UiResponsive.dimension_12,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: BuildDefaultText(
                    text: LanguageKeys.cancel,
                    color: PrimaryColors.hint,
                    fontSize: UiResponsive.dimension_14,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimaryColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: BuildDefaultText(
                    text: LanguageKeys.delete,
                    color: PrimaryColors.white,
                    fontSize: UiResponsive.dimension_14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Color _getStatusColor() {
    if (workOrder.status == 'تم التسليم') {
      return PrimaryColors.success;
    }
    return PrimaryColors.blue;
  }

  Color _getPaymentColor() {
    if (workOrder.isPaid == true || workOrder.isFullyPaid) {
      return PrimaryColors.success;
    }
    return PrimaryColors.error;
  }

  Color _getCardBackgroundColor() {
    if (workOrder.status == 'تم التسليم') {
      return PrimaryColors.success.withValues(alpha: 0.05);
    }
    return PrimaryColors.white;
  }

  Color _getCardBorderColor() {
    if (workOrder.status == 'تم التسليم') {
      return PrimaryColors.success.withValues(alpha: 0.3);
    }
    return PrimaryColors.grey;
  }

  String formatJOD(num price) {
    if (price == 0.5) {
      return "نص دينار";
    }

    if (price == 1) {
      return "دينار";
    }

    if (price == 2) {
      return "دينارين";
    }

    if (price > 2) {
      return "${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)} دنانير";
    }

    return "$price دينار";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(workOrder.id ?? workOrder.customerName ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(
          vertical: UiResponsive.calculateHeight(7.0),
        ),
        decoration: BoxDecoration(
          color: PrimaryColors.danger,
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: UiResponsive.calculateWidth(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.delete_outline,
              color: PrimaryColors.white,
              size: UiResponsive.screenWidth! * 0.06,
            ),
            SizedBox(width: UiResponsive.calculateWidth(8)),
            BuildDefaultText(
              text: LanguageKeys.delete,
              color: PrimaryColors.white,
              fontSize: UiResponsive.dimension_14,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: GestureDetector(
        onTap: () {
          Get.to(WorkOrderDetailsPage(workOrder: workOrder, isEditing: true));
        },
        child: Container(
          padding: const EdgeInsets.all(15.0),
          margin: EdgeInsets.symmetric(
            vertical: UiResponsive.calculateHeight(7.0),
          ),
          decoration: BoxDecoration(
            color: _getCardBackgroundColor(),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: _getCardBorderColor(), width: 0.5),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                color: PrimaryColors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Shelf
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BuildDefaultText(
                      text: workOrder.customerName ?? '',
                      color: PrimaryColors.black,
                      fontSize: UiResponsive.dimension_18,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PrimaryColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: BuildDefaultText(
                      text: 'رف ${workOrder.shelfNumber ?? ''}',
                      color: PrimaryColors.blue,
                      fontSize: UiResponsive.dimension_13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: UiResponsive.calculateHeight(10)),

              // Status and Payment
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: BuildDefaultText(
                      text: workOrder.status ?? '',
                      color: _getStatusColor(),
                      fontSize: UiResponsive.dimension_12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: UiResponsive.calculateWidth(8)),
                  // Payment Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: BuildDefaultText(
                      text: (workOrder.isPaid == true || workOrder.isFullyPaid)
                          ? LanguageKeys.isPaid
                          : LanguageKeys.notPaid,
                      color: _getPaymentColor(),
                      fontSize: UiResponsive.dimension_12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: UiResponsive.calculateHeight(10)),

              // Price Info (only show if price > 0)
              if (workOrder.price != null && workOrder.price! > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildDefaultText(
                          text: LanguageKeys.price,
                          color: PrimaryColors.hint,
                          fontSize: UiResponsive.dimension_12,
                        ),
                        BuildDefaultText(
                          text: formatJOD(workOrder.price ?? 0),
                          color: PrimaryColors.black,
                          fontSize: UiResponsive.dimension_15,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildDefaultText(
                          text: LanguageKeys.paidAmount,
                          color: PrimaryColors.hint,
                          fontSize: UiResponsive.dimension_12,
                        ),
                        BuildDefaultText(
                          text: formatJOD(workOrder.paidAmount ?? 0),
                          color: PrimaryColors.success,
                          fontSize: UiResponsive.dimension_15,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildDefaultText(
                          text: LanguageKeys.remainingAmount,
                          color: PrimaryColors.hint,
                          fontSize: UiResponsive.dimension_12,
                        ),
                        BuildDefaultText(
                          text: formatJOD(workOrder.remainingAmount),
                          color: PrimaryColors.error,
                          fontSize: UiResponsive.dimension_15,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: UiResponsive.calculateHeight(8)),
              ],

              // Dates Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Created Date (always show)
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: UiResponsive.dimension_12,
                        color: PrimaryColors.blue,
                      ),
                      SizedBox(width: UiResponsive.calculateWidth(4)),
                      BuildDefaultText(
                        text:
                            'تاريخ الإضافة: ${_formatDate(workOrder.createdAt)}',
                        color: PrimaryColors.hint,
                        fontSize: UiResponsive.dimension_11,
                      ),
                    ],
                  ),
                  // Delivery Date (if exists)
                  if (workOrder.deliveryDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: UiResponsive.dimension_12,
                          color: PrimaryColors.success,
                        ),
                        SizedBox(width: UiResponsive.calculateWidth(4)),
                        BuildDefaultText(
                          text:
                              'التسليم: ${_formatDate(workOrder.deliveryDate)}',
                          color: PrimaryColors.hint,
                          fontSize: UiResponsive.dimension_11,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
