import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/dialog_helper.dart';
import 'package:balawi_app/core/util/snackbar_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_form_field.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/core/widgets/build_drop_down.dart';
import 'package:balawi_app/features/deliveries/data/models/payment_model.dart';
import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';
import 'package:balawi_app/features/deliveries/deliveries_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WorkOrderDetailsPage extends StatefulWidget {
  final WorkOrderModel? workOrder;
  final bool isEditing;

  const WorkOrderDetailsPage({
    super.key,
    this.workOrder,
    this.isEditing = false,
  });

  @override
  State<WorkOrderDetailsPage> createState() => _WorkOrderDetailsPageState();
}

class _WorkOrderDetailsPageState extends State<WorkOrderDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController priceController;
  late TextEditingController paidAmountController;
  late TextEditingController notesController;

  String? shelfSelected;
  String? statusSelected;
  bool isPaid = false;
  bool isSubmitting = false;
  bool isProcessingPayment = false;

  /// Latest version of the order (updated after adding/deleting payments)
  WorkOrderModel? _order;

  bool get isNewOrder => widget.workOrder == null;

  @override
  void initState() {
    super.initState();
    _order = widget.workOrder;
    nameController = TextEditingController(
      text: widget.workOrder?.customerName ?? '',
    );
    phoneController = TextEditingController(
      text: widget.workOrder?.phoneNumber ?? '',
    );
    priceController = TextEditingController(
      text: widget.workOrder?.price?.toString() ?? '',
    );
    paidAmountController = TextEditingController(
      text: widget.workOrder?.paidAmount?.toString() ?? '',
    );
    notesController = TextEditingController(
      text: widget.workOrder?.notes ?? '',
    );
    shelfSelected = widget.workOrder?.shelfNumber;
    statusSelected = widget.workOrder?.status ?? AppConstants.statusNotReady;
    isPaid = widget.workOrder?.isPaid ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    priceController.dispose();
    paidAmountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (nameController.text.trim().isEmpty) {
      SnackbarHelper.showError(LanguageKeys.pleaseEnterCustomerName);
      return;
    }

    if (shelfSelected == null || shelfSelected!.isEmpty) {
      SnackbarHelper.showError(LanguageKeys.pleaseSelectShelf);
      return;
    }

    if (statusSelected == null || statusSelected!.isEmpty) {
      SnackbarHelper.showError(LanguageKeys.pleaseSelectStatus);
      return;
    }

    // Validate phone number if provided
    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      if (phone.length != 10) {
        SnackbarHelper.showError('رقم الهاتف يجب أن يكون مكون من 10 أرقام');
        return;
      }
      if (!phone.startsWith('07')) {
        SnackbarHelper.showError('رقم الهاتف يجب أن يبدأ بـ 07');
        return;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
        SnackbarHelper.showError('رقم الهاتف يجب أن يحتوي على أرقام فقط');
        return;
      }
    }

    final price = num.tryParse(priceController.text.trim()) ?? 0;
    // When editing, payments are managed in the payments section
    final paidAmount = isNewOrder
        ? (num.tryParse(paidAmountController.text.trim()) ?? 0)
        : (_order?.paidAmount ?? 0);

    if (price > 0 && paidAmount > price) {
      SnackbarHelper.showError('المبلغ المدفوع لا يمكن أن يكون أكبر من السعر');
      return;
    }

    // Require PIN verification only when editing
    if (!isNewOrder) {
      final bool verified = await DialogHelper.showPinVerification(context);
      if (!verified) return;
    }

    if (!mounted) return;
    setState(() {
      isSubmitting = true;
    });

    final DeliveriesController controller = Get.find<DeliveriesController>();

    final workOrder = WorkOrderModel(
      customerName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      shelfNumber: shelfSelected,
      price: price,
      // Only sent for new orders (becomes the first payment)
      paidAmount: isNewOrder ? paidAmount : null,
      isPaid: isNewOrder ? (isPaid || paidAmount >= price) : null,
      status: statusSelected,
      notes: notesController.text.trim(),
    );

    bool success;
    if (isNewOrder) {
      success = await controller.createWorkOrder(workOrder);
    } else {
      success = await controller.updateWorkOrder(
        widget.workOrder!.id!,
        workOrder,
      );
    }

    if (!mounted) return;
    setState(() {
      isSubmitting = false;
    });

    if (success) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 100), () {
        SnackbarHelper.showSuccess(
          isNewOrder
              ? LanguageKeys.workOrderAddedSuccessfully
              : LanguageKeys.workOrderUpdatedSuccessfully,
        );
      });
    } else {
      SnackbarHelper.showError(
        controller.errorMessage ?? LanguageKeys.errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildHeader(),
                if (_order?.orderNumber != null) _buildOrderNumber(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildNameField(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPhoneField(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildShelfAndStatusRow(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPriceAndPaidRow(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                if (isNewOrder) ...[
                  _buildPaidCheckbox(),
                  SizedBox(height: UiResponsive.calculateHeight(20.0)),
                ] else ...[
                  _buildPaymentsSection(),
                  SizedBox(height: UiResponsive.calculateHeight(20.0)),
                ],
                _buildNotesField(),
                SizedBox(height: UiResponsive.calculateHeight(30.0)),
                _buildSaveButton(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
          iconSize: UiResponsive.screenWidth! * 0.07,
        ),
        BuildDefaultText(
          text: isNewOrder
              ? LanguageKeys.addWorkOrder
              : LanguageKeys.workOrderDetails,
          color: PrimaryColors.black,
          fontSize: UiResponsive.dimension_15 + UiResponsive.dimension_15,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        Opacity(
          opacity: 0.0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back),
            iconSize: UiResponsive.screenWidth! * 0.07,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return BuildDefaultFormField(
      controller: nameController,
      label: LanguageKeys.fullName,
      textInputType: TextInputType.name,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPhoneField() {
    return BuildDefaultFormField(
      controller: phoneController,
      maxLength: 10,
      label: LanguageKeys.phoneNumber,
      huntText: "07XXXXXXXX",
      textInputType: TextInputType.phone,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildShelfAndStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDropDown(
            hint: LanguageKeys.selectShelf,
            width: UiResponsive.screenWidth! * 0.42,
            lists: AppConstants.shelfNumbers,
            select: '',
            value: shelfSelected,
            function: (value) {
              if (value != null) {
                setState(() {
                  shelfSelected = value;
                });
              }
            },
          ),
        ),
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDropDown(
            hint: LanguageKeys.selectStatus,
            width: UiResponsive.screenWidth! * 0.42,
            lists: AppConstants.workOrderStatuses,
            select: '',
            value: statusSelected,
            function: (value) {
              if (value != null) {
                setState(() {
                  statusSelected = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndPaidRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDefaultFormField(
            controller: priceController,
            label: LanguageKeys.price,
            textInputType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
        ),
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDefaultFormField(
            controller: paidAmountController,
            label: LanguageKeys.paidAmount,
            textInputType: TextInputType.number,
            textInputAction: TextInputAction.next,
            // When editing, the total comes from the payments list
            enabled: isNewOrder,
            onChanged: () {
              if (!isPaid) return;
              final price = num.tryParse(priceController.text.trim()) ?? 0;
              final paid = num.tryParse(paidAmountController.text.trim()) ?? 0;
              if (paid < price) {
                setState(() => isPaid = false);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaidCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isPaid,
          onChanged: (value) {
            final checked = value ?? false;
            setState(() {
              isPaid = checked;
              if (checked) {
                final price = num.tryParse(priceController.text.trim()) ?? 0;
                final paid =
                    num.tryParse(paidAmountController.text.trim()) ?? 0;
                if (price > 0 && paid < price) {
                  paidAmountController.text = price.toString();
                }
              }
            });
          },
          activeColor: PrimaryColors.blue,
        ),
        BuildDefaultText(
          text: LanguageKeys.isPaid,
          color: PrimaryColors.black,
          fontSize: UiResponsive.dimension_14,
        ),
      ],
    );
  }

  Widget _buildOrderNumber() {
    return Padding(
      padding: EdgeInsets.only(top: UiResponsive.calculateHeight(4)),
      child: BuildDefaultText(
        text: '${LanguageKeys.orderNumberPrefix}${_order!.orderNumber}',
        color: PrimaryColors.hint,
        fontSize: UiResponsive.dimension_16,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatAmount(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  /// Apply an updated order returned by the server
  void _applyUpdatedOrder(WorkOrderModel updated) {
    setState(() {
      _order = updated;
      paidAmountController.text = _formatAmount(updated.paidAmount ?? 0);
    });
  }

  Future<void> _addPayment() async {
    final order = _order;
    if (order?.id == null) return;

    final remaining = order!.remainingAmount;
    final result = await _showAddPaymentDialog(
      remaining > 0 ? remaining : null,
    );
    if (result == null || !mounted) return;

    final bool verified = await DialogHelper.showPinVerification(context);
    if (!verified || !mounted) return;

    setState(() => isProcessingPayment = true);
    final controller = Get.find<DeliveriesController>();
    final updated = await controller.addPayment(
      order.id!,
      amount: result.amount,
      note: result.note,
    );
    if (!mounted) return;
    setState(() => isProcessingPayment = false);

    if (updated != null) {
      _applyUpdatedOrder(updated);
      SnackbarHelper.showSuccess(LanguageKeys.paymentAddedSuccessfully);
    } else {
      SnackbarHelper.showError(
        controller.errorMessage ?? LanguageKeys.errorOccurred,
      );
    }
  }

  Future<void> _deletePayment(PaymentModel payment) async {
    final order = _order;
    if (order?.id == null || payment.id == null) return;

    // PIN dialog doubles as the delete confirmation
    final bool verified = await DialogHelper.showPinVerification(
      context,
      title: LanguageKeys.deletePaymentTitle,
    );
    if (!verified || !mounted) return;

    setState(() => isProcessingPayment = true);
    final controller = Get.find<DeliveriesController>();
    final updated = await controller.deletePayment(order!.id!, payment.id!);
    if (!mounted) return;
    setState(() => isProcessingPayment = false);

    if (updated != null) {
      _applyUpdatedOrder(updated);
      SnackbarHelper.showSuccess(LanguageKeys.paymentDeletedSuccessfully);
    } else {
      SnackbarHelper.showError(
        controller.errorMessage ?? LanguageKeys.errorOccurred,
      );
    }
  }

  /// Ask for payment amount (pre-filled with the remaining amount) and note
  Future<({num amount, String note})?> _showAddPaymentDialog(
    num? suggestedAmount,
  ) {
    return showDialog<({num amount, String note})>(
      context: context,
      builder: (context) => _AddPaymentDialog(
        initialAmount: suggestedAmount != null
            ? _formatAmount(suggestedAmount)
            : '',
      ),
    );
  }

  Widget _buildPaymentsSection() {
    final order = _order;
    final payments = order?.payments ?? const <PaymentModel>[];
    final remaining = order?.remainingAmount ?? 0;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PrimaryColors.black.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BuildDefaultText(
                text: LanguageKeys.payments,
                color: PrimaryColors.black,
                fontSize: UiResponsive.dimension_16,
                fontWeight: FontWeight.bold,
              ),
              isProcessingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: remaining > 0 ? _addPayment : null,
                      icon: const Icon(Icons.add),
                      label: const Text(LanguageKeys.addPayment),
                    ),
            ],
          ),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BuildDefaultText(
                text: LanguageKeys.noPayments,
                color: PrimaryColors.hint,
                fontSize: UiResponsive.dimension_14,
              ),
            ),
          ...payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  BuildDefaultText(
                    text: _formatAmount(payment.amount),
                    color: payment.amount < 0
                        ? PrimaryColors.error
                        : PrimaryColors.black,
                    fontSize: UiResponsive.dimension_16,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(width: UiResponsive.calculateWidth(12)),
                  Expanded(
                    child: BuildDefaultText(
                      text: [
                        if (payment.paidAt != null)
                          dateFormat.format(payment.paidAt!),
                        if (payment.note.isNotEmpty) payment.note,
                      ].join(' • '),
                      color: PrimaryColors.hint,
                      fontSize: UiResponsive.dimension_13,
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: isProcessingPayment
                        ? null
                        : () => _deletePayment(payment),
                    icon: const Icon(Icons.delete_outline),
                    color: PrimaryColors.error,
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          BuildDefaultText(
            text: remaining > 0
                ? '${LanguageKeys.remainingAmount}: ${_formatAmount(remaining)}'
                : LanguageKeys.fullyPaid,
            color: remaining > 0 ? PrimaryColors.error : PrimaryColors.success,
            fontSize: UiResponsive.dimension_14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: notesController,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: TextStyle(
        color: PrimaryColors.black,
        fontSize: UiResponsive.screenWidth! * 0.045,
      ),
      decoration: InputDecoration(
        labelText: LanguageKeys.notes,
        labelStyle: TextStyle(
          color: PrimaryColors.hint,
          fontSize: UiResponsive.screenWidth! * 0.05,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsetsDirectional.only(
          start: UiResponsive.screenWidth! * 0.05,
          top: UiResponsive.screenHeight! * 0.019,
          bottom: UiResponsive.screenHeight! * 0.019,
        ),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: PrimaryColors.black.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: PrimaryColors.black.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: PrimaryColors.black.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: UiResponsive.calculateHeight(55),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _saveWorkOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: PrimaryColors.blue,
          disabledBackgroundColor: PrimaryColors.blue.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: PrimaryColors.white,
                  strokeWidth: 2,
                ),
              )
            : BuildDefaultText(
                text: isNewOrder
                    ? LanguageKeys.addWorkOrder
                    : LanguageKeys.save,
                color: PrimaryColors.white,
                fontSize: UiResponsive.dimension_16,
                fontWeight: FontWeight.w600,
              ),
      ),
    );
  }
}

/// Add payment dialog. Owns its text controllers and disposes them only
/// after the dialog is fully removed (after the close animation).
class _AddPaymentDialog extends StatefulWidget {
  final String initialAmount;

  const _AddPaymentDialog({required this.initialAmount});

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  late final TextEditingController amountController;
  final TextEditingController noteController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    final amount = num.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => error = LanguageKeys.invalidPaymentAmount);
      return;
    }
    Navigator.of(
      context,
    ).pop((amount: amount, note: noteController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: BuildDefaultText(
        text: LanguageKeys.addPayment,
        color: PrimaryColors.black,
        fontSize: UiResponsive.dimension_18,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: LanguageKeys.paymentAmount,
              errorText: error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: UiResponsive.calculateHeight(12)),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: LanguageKeys.paymentNote,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: BuildDefaultText(
            text: LanguageKeys.cancel,
            color: PrimaryColors.hint,
            fontSize: UiResponsive.dimension_14,
          ),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: BuildDefaultText(
            text: LanguageKeys.confirm,
            color: PrimaryColors.white,
            fontSize: UiResponsive.dimension_14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
