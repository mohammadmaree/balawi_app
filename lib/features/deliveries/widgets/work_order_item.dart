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
            color: PrimaryColors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: PrimaryColors.grey, width: 0.5),
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

              // Price Info
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
                        text: '${workOrder.price ?? 0} ل.س',
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
                        text: '${workOrder.paidAmount ?? 0} ل.س',
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
                        text: '${workOrder.remainingAmount} ل.س',
                        color: PrimaryColors.error,
                        fontSize: UiResponsive.dimension_15,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),

              // Date if delivered
              if (workOrder.deliveryDate != null) ...[
                SizedBox(height: UiResponsive.calculateHeight(8)),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: UiResponsive.dimension_12,
                      color: PrimaryColors.hint,
                    ),
                    SizedBox(width: UiResponsive.calculateWidth(4)),
                    BuildDefaultText(
                      text:
                          '${LanguageKeys.deliveryDate}: ${_formatDate(workOrder.deliveryDate)}',
                      color: PrimaryColors.hint,
                      fontSize: UiResponsive.dimension_12,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
