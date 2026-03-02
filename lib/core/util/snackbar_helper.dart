import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class for showing snackbars with consistent styling
class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? LanguageKeys.success,
      message,
      backgroundColor: PrimaryColors.success,
      colorText: PrimaryColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? LanguageKeys.error,
      message,
      backgroundColor: PrimaryColors.danger,
      colorText: PrimaryColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
