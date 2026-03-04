import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/features/deliveries/deliveries_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WorkOrderFilterBottomSheet extends StatefulWidget {
  const WorkOrderFilterBottomSheet({super.key});

  @override
  State<WorkOrderFilterBottomSheet> createState() =>
      _WorkOrderFilterBottomSheetState();
}

class _WorkOrderFilterBottomSheetState
    extends State<WorkOrderFilterBottomSheet> {
  String? selectedStatus;
  String? selectedShelf;
  bool? selectedPaymentStatus;
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<DeliveriesController>();
    selectedStatus = controller.selectedStatus;
    selectedShelf = controller.selectedShelf;
    selectedPaymentStatus = controller.selectedPaymentStatus;
    selectedDateFrom = controller.selectedDateFrom;
    selectedDateTo = controller.selectedDateTo;
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (selectedDateFrom ?? DateTime.now())
          : (selectedDateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PrimaryColors.blue,
              onPrimary: PrimaryColors.white,
              surface: PrimaryColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          selectedDateFrom = picked;
        } else {
          selectedDateTo = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UiResponsive.screenHeight! * 0.85,
      padding: const EdgeInsets.only(
        top: 26.0,
        left: 15.0,
        right: 15.0,
        bottom: 15.0,
      ),
      decoration: const BoxDecoration(
        color: PrimaryColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height:
                        UiResponsive.dimension_18 + UiResponsive.dimension_18,
                    width:
                        UiResponsive.dimension_18 + UiResponsive.dimension_18,
                    padding: const EdgeInsets.all(4.0),
                    color: PrimaryColors.white,
                    child: Icon(Icons.close, size: UiResponsive.dimension_25),
                  ),
                ),
                BuildDefaultText(
                  text: LanguageKeys.filter,
                  color: PrimaryColors.black,
                  fontSize: UiResponsive.dimension_22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatus = null;
                      selectedShelf = null;
                      selectedPaymentStatus = null;
                      selectedDateFrom = null;
                      selectedDateTo = null;
                    });
                  },
                  child: BuildDefaultText(
                    text: LanguageKeys.clearFilters,
                    color: PrimaryColors.error,
                    fontSize: UiResponsive.dimension_14,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: UiResponsive.calculateHeight(30.0)),

          // Status Filter
          _buildSectionTitle(LanguageKeys.status),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          _buildStatusOptions(),
          SizedBox(height: UiResponsive.calculateHeight(25)),

          // Shelf Filter
          _buildSectionTitle(LanguageKeys.shelfNumber),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          _buildShelfOptions(),
          SizedBox(height: UiResponsive.calculateHeight(25)),

          // Payment Status Filter
          _buildSectionTitle(LanguageKeys.isPaid),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          _buildPaymentStatusOptions(),
          SizedBox(height: UiResponsive.calculateHeight(25)),

          // Date Filter
          _buildSectionTitle('التاريخ'),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          _buildDateFilters(),
          SizedBox(height: UiResponsive.calculateHeight(40)),

          // Apply Button
          _buildApplyButton(),
          SizedBox(height: UiResponsive.calculateHeight(20)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: BuildDefaultText(
        text: title,
        color: PrimaryColors.black,
        fontSize: UiResponsive.dimension_16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFilterChip(
          LanguageKeys.allStatuses,
          null,
          selectedStatus,
          (value) => setState(() => selectedStatus = value),
        ),
        ...AppConstants.workOrderStatuses.map(
          (status) => _buildFilterChip(
            status,
            status,
            selectedStatus,
            (value) => setState(() => selectedStatus = value),
          ),
        ),
      ],
    );
  }

  Widget _buildShelfOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFilterChip(
          LanguageKeys.allShelves,
          null,
          selectedShelf,
          (value) => setState(() => selectedShelf = value),
        ),
        ...AppConstants.shelfNumbers.map(
          (shelf) => _buildFilterChip(
            'رف $shelf',
            shelf,
            selectedShelf,
            (value) => setState(() => selectedShelf = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFilterChip(
          LanguageKeys.allPaymentStatuses,
          null,
          selectedPaymentStatus == null ? null : 'all',
          (value) => setState(() => selectedPaymentStatus = null),
        ),
        _buildFilterChip(
          LanguageKeys.isPaid,
          'paid',
          selectedPaymentStatus == true ? 'paid' : null,
          (value) => setState(() => selectedPaymentStatus = true),
        ),
        _buildFilterChip(
          LanguageKeys.notPaid,
          'notpaid',
          selectedPaymentStatus == false ? 'notpaid' : null,
          (value) => setState(() => selectedPaymentStatus = false),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? currentValue,
    Function(String?) onTap,
  ) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? PrimaryColors.blue
              : PrimaryColors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? PrimaryColors.blue : PrimaryColors.grey,
            width: 1,
          ),
        ),
        child: BuildDefaultText(
          text: label,
          color: isSelected ? PrimaryColors.white : PrimaryColors.black,
          fontSize: UiResponsive.dimension_13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Column(
      children: [
        // Date From
        GestureDetector(
          onTap: () => _selectDate(context, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: PrimaryColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PrimaryColors.grey, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BuildDefaultText(
                  text: selectedDateFrom != null
                      ? 'من: ${_formatDate(selectedDateFrom)}'
                      : 'من تاريخ',
                  color: selectedDateFrom != null
                      ? PrimaryColors.black
                      : PrimaryColors.hint,
                  fontSize: UiResponsive.dimension_14,
                ),
                Icon(
                  Icons.calendar_today,
                  color: PrimaryColors.blue,
                  size: UiResponsive.dimension_18,
                ),
              ],
            ),
          ),
        ),
        if (selectedDateFrom != null) ...[
          SizedBox(height: UiResponsive.calculateHeight(10)),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDateFrom = null;
              });
            },
            child: BuildDefaultText(
              text: 'مسح التاريخ',
              color: PrimaryColors.error,
              fontSize: UiResponsive.dimension_12,
              textDecoration: TextDecoration.underline,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () async {
        final controller = Get.find<DeliveriesController>();
        await controller.applyFilters(
          status: selectedStatus,
          shelf: selectedShelf,
          paymentStatus: selectedPaymentStatus,
          dateFrom: selectedDateFrom,
          dateTo: selectedDateTo,
        );
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.0),
          color: PrimaryColors.blue,
        ),
        child: Center(
          child: BuildDefaultText(
            text: LanguageKeys.apply,
            color: PrimaryColors.white,
            fontSize: UiResponsive.dimension_16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
