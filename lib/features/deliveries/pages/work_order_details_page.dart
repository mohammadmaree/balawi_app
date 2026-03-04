import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/dialog_helper.dart';
import 'package:balawi_app/core/util/snackbar_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_form_field.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/core/widgets/build_drop_down.dart';
import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';
import 'package:balawi_app/features/deliveries/deliveries_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  bool get isNewOrder => widget.workOrder == null;

  @override
  void initState() {
    super.initState();
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
    statusSelected = widget.workOrder?.status ?? AppConstants.statusReady;
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

    final price = num.tryParse(priceController.text.trim()) ?? 0;
    final paidAmount = num.tryParse(paidAmountController.text.trim()) ?? 0;

    final workOrder = WorkOrderModel(
      customerName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      shelfNumber: shelfSelected,
      price: price,
      paidAmount: paidAmount,
      isPaid: isPaid || paidAmount >= price,
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
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildNameField(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPhoneField(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildShelfAndStatusRow(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPriceAndPaidRow(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPaidCheckbox(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
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
            setState(() {
              isPaid = value ?? false;
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
