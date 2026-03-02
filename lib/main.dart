import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/util/cache_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/features/customers/pages/customers_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Initialize CacheHelper for managing cached data
  await CacheHelper.init();
  runApp(EasyLocalization(
      supportedLocales: const [Locale('ar')],
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      path: 'assets/translations',
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Balawi',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: PrimaryColors.white).copyWith(background: PrimaryColors.white),
          // dialogTheme: DialogTheme(backgroundColor: PrimaryColors.white),
          scaffoldBackgroundColor: PrimaryColors.white
      ),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
      onGenerateRoute: (routeSettings) => UiResponsive.onGenerateRoute(routeSettings, const CustomersPage()),
    );
  }
}