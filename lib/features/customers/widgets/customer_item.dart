import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/features/customers/data/models/customer_model.dart';
import 'package:balawi_app/features/customers/pages/customer_details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerItem extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onDelete;

  const CustomerItem({super.key, required this.customer, this.onDelete});

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
                    text: customer.fullName ?? '',
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(customer.id ?? customer.fullName ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(
          vertical: UiResponsive.calculateHeight(7.0),
        ),
        decoration: BoxDecoration(
          color: PrimaryColors.danger,
          borderRadius: BorderRadius.circular(6.0),
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
          Get.to(CustomerDetailsPage(customer: customer, isEditing: true));
        },
        child: Container(
          padding: EdgeInsets.only(left: 15.0, right: 10.0),
          margin: EdgeInsets.symmetric(
            vertical: UiResponsive.calculateHeight(7.0),
          ),
          height: UiResponsive.calculateHeight(60.0),
          decoration: BoxDecoration(
            color: PrimaryColors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: PrimaryColors.grey, width: 0.5),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                color: PrimaryColors.grey.withValues(alpha: 0.2),
                blurRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BuildDefaultText(
                  text: customer.fullName ?? "",
                  color: PrimaryColors.black,
                  fontSize: UiResponsive.dimension_18,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BuildDefaultText(
                    text: LanguageKeys.viewMore,
                    color: PrimaryColors.hint,
                    fontSize: UiResponsive.dimension_12,
                  ),
                  SizedBox(width: UiResponsive.calculateWidth(4)),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: UiResponsive.dimension_12,
                    color: PrimaryColors.hint,
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
