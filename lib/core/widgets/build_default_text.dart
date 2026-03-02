import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/app_constants.dart';
import 'package:flutter/material.dart';

class BuildDefaultText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? height;
  final TextOverflow? textOverflow;
  final TextDecoration? textDecoration;

  const BuildDefaultText({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.height,
    this.textOverflow,
    this.textDecoration,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight ?? FontWeight.w500,
        fontFamily: AppConstants.TAJAWAL,
        height: height ?? 1.8,
        decoration: textDecoration ?? TextDecoration.none,
        decorationColor: PrimaryColors.black.withValues(alpha: 0.4),
        decorationThickness: 1.0,
      ),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines ?? 1,
      overflow: textOverflow ?? TextOverflow.ellipsis,
    );
  }
}
