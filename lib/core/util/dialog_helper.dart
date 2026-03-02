import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for showing common dialogs
class DialogHelper {
  DialogHelper._();

  /// Show PIN verification dialog
  /// Returns true if PIN is correct, false otherwise
  static Future<bool> showPinVerification(
    BuildContext context, {
    String? title,
    String? message,
    String pin = AppConstants.defaultPin,
  }) async {
    final TextEditingController pinController = TextEditingController();
    bool isError = false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: PrimaryColors.blue,
                        size: UiResponsive.screenWidth! * 0.07,
                      ),
                      SizedBox(width: UiResponsive.calculateWidth(10)),
                      BuildDefaultText(
                        text: title ?? LanguageKeys.pinVerificationTitle,
                        color: PrimaryColors.black,
                        fontSize: UiResponsive.dimension_18,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BuildDefaultText(
                        text: message ?? LanguageKeys.pinVerificationMessage,
                        color: PrimaryColors.black,
                        fontSize: UiResponsive.dimension_14,
                      ),
                      SizedBox(height: UiResponsive.calculateHeight(16)),
                      TextField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: UiResponsive.dimension_22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '****',
                          hintStyle: TextStyle(
                            color: PrimaryColors.hint,
                            letterSpacing: 8,
                          ),
                          border: _buildBorder(isError, false),
                          focusedBorder: _buildBorder(isError, true),
                          enabledBorder: _buildBorder(isError, false),
                        ),
                        onChanged: (value) {
                          if (isError) {
                            setState(() => isError = false);
                          }
                        },
                      ),
                      if (isError)
                        Padding(
                          padding: EdgeInsets.only(
                            top: UiResponsive.calculateHeight(8),
                          ),
                          child: BuildDefaultText(
                            text: LanguageKeys.pinIncorrect,
                            color: PrimaryColors.error,
                            fontSize: UiResponsive.dimension_12,
                          ),
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
                      onPressed: () {
                        if (pinController.text == pin) {
                          Navigator.of(context).pop(true);
                        } else {
                          setState(() => isError = true);
                          pinController.clear();
                        }
                      },
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
              },
            );
          },
        ) ??
        false;
  }

  static OutlineInputBorder _buildBorder(bool isError, bool isFocused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isError
            ? PrimaryColors.error
            : (isFocused ? PrimaryColors.blue : PrimaryColors.grey),
        width: isFocused ? 2 : 1,
      ),
    );
  }
}
