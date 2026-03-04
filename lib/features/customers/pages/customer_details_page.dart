import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/dialog_helper.dart';
import 'package:balawi_app/core/util/snackbar_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_form_field.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/core/widgets/build_drop_down.dart';
import 'package:balawi_app/features/customers/customers_controller.dart';
import 'package:balawi_app/features/customers/data/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerModel? customer;
  final bool isEditing;

  const CustomerDetailsPage({super.key, this.customer, this.isEditing = false});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController pantsHeightController;
  late TextEditingController waistWidthController;
  late TextEditingController pantsLegWidthController;
  late TextEditingController noteController;

  String? typeSelected;
  bool isSubmitting = false;

  bool get isNewCustomer => widget.customer == null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.customer?.fullName ?? '',
    );
    phoneNumberController = TextEditingController(
      text: widget.customer?.phoneNumber ?? '',
    );
    pantsHeightController = TextEditingController(
      text: widget.customer?.pantsHeight?.toString() ?? '',
    );
    waistWidthController = TextEditingController(
      text: widget.customer?.waistWidth?.toString() ?? '',
    );
    pantsLegWidthController = TextEditingController(
      text: widget.customer?.pantsLegWidth?.toString() ?? '',
    );
    noteController = TextEditingController(text: widget.customer?.notes ?? '');
    typeSelected = widget.customer?.type;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    pantsHeightController.dispose();
    waistWidthController.dispose();
    pantsLegWidthController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectType(String type) async {
    setState(() {
      typeSelected = type;
    });
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    if (nameController.text.trim().isEmpty) {
      SnackbarHelper.showError(LanguageKeys.pleaseEnterCustomerName);
      return;
    }

    // Validate phone number if provided
    final phone = phoneNumberController.text.trim();
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

    // Require PIN verification only when editing existing customer
    if (!isNewCustomer) {
      final bool verified = await DialogHelper.showPinVerification(context);
      if (!verified) return;
    }

    if (!mounted) return;
    setState(() {
      isSubmitting = true;
    });

    final CustomerController customerController =
        Get.find<CustomerController>();

    final customer = CustomerModel(
      fullName: nameController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      pantsHeight: num.tryParse(pantsHeightController.text.trim()) ?? 0,
      waistWidth: num.tryParse(waistWidthController.text.trim()) ?? 0,
      pantsLegWidth: num.tryParse(pantsLegWidthController.text.trim()) ?? 0,
      type: typeSelected ?? '',
      notes: noteController.text.trim(),
    );

    bool success;
    if (isNewCustomer) {
      success = await customerController.createCustomer(customer);
    } else {
      success = await customerController.updateCustomer(
        widget.customer!.id!,
        customer,
      );
    }

    if (!mounted) return;
    setState(() {
      isSubmitting = false;
    });

    if (success) {
      Get.back();
      Future.delayed(Duration(milliseconds: 100), () {
        SnackbarHelper.showSuccess(
          isNewCustomer
              ? LanguageKeys.customerAddedSuccessfully
              : LanguageKeys.customerUpdatedSuccessfully,
        );
      });
    } else {
      SnackbarHelper.showError(
        customerController.errorMessage ?? LanguageKeys.errorOccurred,
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
                _buildDimensionsRow(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPantsLegWidthField(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildTypeDropdown(),
                SizedBox(height: UiResponsive.calculateHeight(20.0)),
                _buildPhoneField(),
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
          icon: Icon(Icons.arrow_back),
          iconSize: UiResponsive.screenWidth! * 0.07,
        ),
        BuildDefaultText(
          text: isNewCustomer
              ? LanguageKeys.addCustomer
              : LanguageKeys.customerDetails,
          color: PrimaryColors.black,
          fontSize: UiResponsive.dimension_15 + UiResponsive.dimension_15,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        Opacity(
          opacity: 0.0,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_back),
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

  Widget _buildDimensionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDefaultFormField(
            controller: pantsHeightController,
            label: LanguageKeys.pantsHeight,
            textInputType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 3,
          ),
        ),
        SizedBox(
          width: UiResponsive.screenWidth! * 0.42,
          child: BuildDefaultFormField(
            controller: waistWidthController,
            label: LanguageKeys.waistWidth,
            textInputType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildPantsLegWidthField() {
    return BuildDefaultFormField(
      controller: pantsLegWidthController,
      label: LanguageKeys.pantsLegWidth,
      textInputType: TextInputType.number,
      textInputAction: TextInputAction.next,
      maxLength: 3,
    );
  }

  Widget _buildTypeDropdown() {
    return BuildDropDown(
      hint: LanguageKeys.selectType,
      width: UiResponsive.screenWidth! * 0.8,
      lists: AppConstants.customerTypes,
      select: '',
      value: typeSelected,
      function: (value) {
        if (value != null) {
          selectType(value);
        }
      },
    );
  }

  Widget _buildPhoneField() {
    return BuildDefaultFormField(
      controller: phoneNumberController,
      label: LanguageKeys.phoneNumber,
      huntText: "07XXXXXXXX",
      textInputType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: noteController,
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
        onPressed: isSubmitting ? null : _saveCustomer,
        style: ElevatedButton.styleFrom(
          backgroundColor: PrimaryColors.blue,
          disabledBackgroundColor: PrimaryColors.blue.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: PrimaryColors.white,
                  strokeWidth: 2,
                ),
              )
            : BuildDefaultText(
                text: isNewCustomer
                    ? LanguageKeys.addCustomerButton
                    : LanguageKeys.saveChangesButton,
                color: PrimaryColors.white,
                fontSize: UiResponsive.dimension_16,
                fontWeight: FontWeight.w600,
              ),
      ),
    );
  }
}
