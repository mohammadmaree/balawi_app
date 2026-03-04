import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildDefaultFormField extends StatelessWidget {
  final TextEditingController controller;
  final String huntText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  String? label;
  bool? hidePassword;
  Widget? suffixIcon;
  VoidCallback? onChanged;
  bool? isValid;
  bool? enabled;
  int? maxLength;
  Color? textColor;

  BuildDefaultFormField({
    required this.controller,
    required this.huntText,
    required this.textInputType,
    required this.textInputAction,
    this.label,
    this.hidePassword,
    this.suffixIcon,
    this.onChanged,
    this.isValid,
    this.enabled,
    this.maxLength,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled ?? true,
      style: textColor != null ? TextStyle(color: textColor!) : null,
      controller: controller,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      obscureText: hidePassword ?? false,
      inputFormatters: maxLength != null
          ? [
              LengthLimitingTextInputFormatter(
                maxLength,
              ), // Limit to 12 characters
            ]
          : null,
      decoration: InputDecoration(
        //    label: label!=null?label!:SizedBox(),
        labelText: label ?? huntText,
        labelStyle: TextStyle(
          color: PrimaryColors.hint,
          fontSize: UiResponsive.screenWidth! * 0.05,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // hintText: huntText,
        // hintStyle: TextStyle(
        //   color: PrimaryColors.hint,
        //   fontSize: UiResponsive.screenWidth! * 0.04,
        //   fontWeight: FontWeight.w400,
        //   fontFamily: AppConstants.TAJAWAL,
        // ),
        contentPadding: EdgeInsetsDirectional.only(
          start: UiResponsive.screenWidth! * 0.05,
          top: UiResponsive.screenHeight! * 0.027,
          bottom: UiResponsive.screenHeight! * 0.027,
        ),
        //border: InputBorder.none,
        suffixIcon: suffixIcon ?? SizedBox(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiResponsive.dimension_11),
          borderSide: BorderSide(
            color: (isValid ?? true)
                ? PrimaryColors.black.withValues(alpha: 0.5)
                : PrimaryColors.error,
            width: 0.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiResponsive.dimension_11),
          borderSide: BorderSide(
            color: (isValid ?? true)
                ? PrimaryColors.black.withValues(alpha: 0.5)
                : PrimaryColors.error,
            width: 0.6,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiResponsive.dimension_11),
          borderSide: BorderSide(
            color: (isValid ?? true)
                ? PrimaryColors.black.withValues(alpha: 0.5)
                : PrimaryColors.error,
            width: 0.6,
          ),
        ),
      ),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!();
        }
      },
    );
  }
}
