import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/features/customers/pages/customers_page.dart';
import 'package:balawi_app/features/deliveries/pages/deliveries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationMain extends StatefulWidget {
  const NavigationMain({super.key});

  @override
  State<NavigationMain> createState() => _NavigationMainState();
}

class _NavigationMainState extends State<NavigationMain> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const CustomersPage(), const DeliveriesPage()];

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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: PrimaryColors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: PrimaryColors.white,
          selectedItemColor: PrimaryColors.blue,
          unselectedItemColor: PrimaryColors.hint,
          selectedFontSize: UiResponsive.dimension_12,
          unselectedFontSize: UiResponsive.dimension_11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'الزبائن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'التسليمات',
            ),
          ],
        ),
      ),
    );
  }
}
