import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UiResponsive{
  static double? screenWidth;
  static double? screenHeight;

  static void getScreenDimensions(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.right -
        MediaQuery.of(context).padding.left;
    screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
  }
  static onGenerateRoute(RouteSettings routeSettings ,Widget page) {
    return MaterialPageRoute(
      builder: (context) {
        getScreenDimensions(context);
        return page;
      },
      settings: routeSettings,
    );
  }
  static bool isTablet(){
    final bool isTablet;
    final double devicePixelRatio = ui.window.devicePixelRatio;
    final ui.Size size = ui.window.physicalSize;
    final double width = size.width;
    final double height = size.height;

    if((devicePixelRatio == 2 || devicePixelRatio < 2) && (width >= 1200 || height >= 1920)) {
      isTablet = true;
    }
    else {
      isTablet = false;
    }
    return isTablet;
  }

  static double tabletIcon(double sizeM, double sizeT){
    if(isTablet()) {
      return sizeT;
    } else{
      return sizeM;
    }
  }

  static double calculateWidth(double width){
    double percentage = (width /  375.0) * 100;
    // print(percentage * screenWidth! / 100);
    return percentage * screenWidth! / 100;
  }

  static double calculateHeight(double height){
    double percentage = (height /  812.0) * 100;
    //print(percentage * screenHeight! / 100);
    return percentage * screenHeight! / 100;
  }


  static double dimension_8 = screenWidth!*0.0106+screenHeight!*0.0055;
  static double dimension_9 = screenWidth!*0.0126+screenHeight!*0.006;
  static double dimension_10 = screenWidth!*0.014+screenHeight!*0.00656;
  static double dimension_11 = screenWidth!*0.015+screenHeight!*0.00725;
  static double dimension_11_5 = screenWidth!*0.0155+screenHeight!*0.0076;
  static double dimension_12 = screenWidth!*0.016+screenHeight!*0.008;
  static double dimension_13 = screenWidth!*0.0175+screenHeight!*0.0085;
  static double dimension_14 = screenWidth!*0.0185+screenHeight!*0.0092;
  static double dimension_15 = screenWidth!*0.0194+screenHeight!*0.01;
  static double dimension_16 = screenWidth!*0.0205+screenHeight!*0.01066;
  static double dimension_17 = screenWidth!*0.022+screenHeight!*0.0111;
  static double dimension_18 = screenWidth!*0.0235+screenHeight!*0.01165;
  static double dimension_19 = screenWidth!*0.0253+screenHeight!*0.012;
  static double dimension_20 = screenWidth!*0.027+screenHeight!*0.0124;
  static double dimension_21 = screenWidth!*0.0285+screenHeight!*0.0129;
  static double dimension_22 = screenWidth!*0.03+screenHeight!*0.0134;
  static double dimension_23 = screenWidth!*0.0315+screenHeight!*0.0139;
  static double dimension_24 = screenWidth!*0.033+screenHeight!*0.0143;
  static double dimension_25 = screenWidth!*0.0345+screenHeight!*0.0148;


}