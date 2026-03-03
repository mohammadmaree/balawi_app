import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: PrimaryColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              SizedBox(height: UiResponsive.calculateHeight(20.0)),
              BuildDefaultText(
                text: 'التسليمات',
                color: PrimaryColors.black,
                fontSize: UiResponsive.dimension_15 + UiResponsive.dimension_15,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: UiResponsive.calculateHeight(40.0)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: UiResponsive.screenWidth! * 0.25,
                        color: PrimaryColors.hint,
                      ),
                      SizedBox(height: UiResponsive.calculateHeight(20)),
                      BuildDefaultText(
                        text: 'قريباً',
                        color: PrimaryColors.hint,
                        fontSize: UiResponsive.dimension_20,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: UiResponsive.calculateHeight(8)),
                      BuildDefaultText(
                        text: 'ميزة التسليمات قيد التطوير',
                        color: PrimaryColors.hint,
                        fontSize: UiResponsive.dimension_14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
