import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/images.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/snackbar_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/features/customers/customers_controller.dart';
import 'package:balawi_app/features/customers/pages/customer_details_page.dart';
import 'package:balawi_app/features/customers/widgets/customer_item.dart';
import 'package:balawi_app/features/customers/widgets/search_filter_button_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late ScrollController _scrollController;
  late CustomerController customerController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: PrimaryColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      customerController.fetchCustomers(loadMore: true);
    }
  }

  Future<void> _handleDelete(String? customerId) async {
    if (customerId == null) return;

    final success = await customerController.deleteCustomer(customerId);
    if (success) {
      SnackbarHelper.showSuccess(LanguageKeys.customerDeletedSuccessfully);
    } else {
      SnackbarHelper.showError(
        customerController.errorMessage ?? LanguageKeys.deleteCustomerFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    customerController = Get.put(CustomerController());
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<CustomerController>(
          builder: (_) {
            return RefreshIndicator(
              onRefresh: () => customerController.fetchCustomers(refresh: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: UiResponsive.calculateHeight(20.0)),
                          BuildDefaultText(
                            text: 'الزبائن',
                            color: PrimaryColors.black,
                            fontSize:
                                UiResponsive.dimension_15 +
                                UiResponsive.dimension_15,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: UiResponsive.calculateHeight(20.0)),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SearchHeaderDelegate(
                        child: Container(
                          color: PrimaryColors.white,
                          padding: EdgeInsets.only(
                            bottom: UiResponsive.calculateHeight(10.0),
                          ),
                          child: _buildSearchField(),
                        ),
                      ),
                    ),
                    // Loading state
                    if (customerController.isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PrimaryColors.blue,
                          ),
                        ),
                      )
                    // Error state
                    else if (customerController.errorMessage != null &&
                        customerController.customers.isEmpty)
                      SliverFillRemaining(child: _buildErrorWidget())
                    // Empty state
                    else if (customerController.customers.isEmpty)
                      SliverFillRemaining(child: _buildEmptyWidget())
                    // Customer list
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == customerController.customers.length) {
                            // Loading more indicator
                            if (customerController.isLoadingMore) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: UiResponsive.calculateHeight(20),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: PrimaryColors.blue,
                                  ),
                                ),
                              );
                            }
                            // Bottom padding
                            return SizedBox(
                              height: UiResponsive.calculateHeight(75.0),
                            );
                          }

                          final customer = customerController.customers[index];
                          return CustomerItem(
                            customer: customer,
                            onDelete: () => _handleDelete(customer.id),
                          );
                        }, childCount: customerController.customers.length + 1),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customers_fab',
        onPressed: () {
          Get.to(CustomerDetailsPage(isEditing: false));
        },
        backgroundColor: PrimaryColors.blue,
        child: Icon(Icons.add, color: PrimaryColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: UiResponsive.screenWidth! * 0.9,
            child: TextFormField(
              controller: customerController.searchTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: PrimaryColors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: PrimaryColors.white,
                hintText: 'ابحث عن الاسم',
                hintStyle: TextStyle(
                  fontSize: UiResponsive.dimension_14,
                  color: Color(0xFF9A9DA3),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'IBMPlexSansArabic',
                ),
                suffixIcon: GestureDetector(
                  onTap: () => customerController.search(),
                  child: SvgPicture.asset(
                    PrimaryImages.search,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                prefixIcon:
                    customerController.searchQuery != null &&
                        customerController.searchQuery!.isNotEmpty
                    ? GestureDetector(
                        onTap: () => customerController.clearSearch(),
                        child: Icon(
                          Icons.clear,
                          color: PrimaryColors.hint,
                          size: UiResponsive.dimension_20,
                        ),
                      )
                    : null,
                focusColor: PrimaryColors.grey,
                contentPadding: EdgeInsets.only(
                  top: UiResponsive.calculateHeight(20.0),
                  bottom: UiResponsive.calculateHeight(22.0),
                  right: UiResponsive.calculateWidth(15.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: PrimaryColors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: PrimaryColors.grey,
                    width: 1.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: PrimaryColors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: PrimaryColors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              onFieldSubmitted: (String? v) {
                customerController.search();
              },
              onChanged: (v) {
                // Debounced search or immediate update of UI
              },
            ),
          ),
        ),
        SizedBox(width: UiResponsive.calculateWidth(10)),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return SearchFilterButtonSheet();
              },
            );
          },
          child: Container(
            width: UiResponsive.calculateWidth(50),
            height: UiResponsive.calculateHeight(55),
            decoration: BoxDecoration(
              color: PrimaryColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.filter_list,
              color: PrimaryColors.white,
              size: UiResponsive.dimension_24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: UiResponsive.screenWidth! * 0.15,
            color: PrimaryColors.error,
          ),
          SizedBox(height: UiResponsive.calculateHeight(16)),
          BuildDefaultText(
            text: customerController.errorMessage ?? 'حدث خطأ',
            color: PrimaryColors.black,
            fontSize: UiResponsive.dimension_16,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UiResponsive.calculateHeight(16)),
          ElevatedButton(
            onPressed: () => customerController.fetchCustomers(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PrimaryColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: BuildDefaultText(
              text: LanguageKeys.tryAgain,
              color: PrimaryColors.white,
              fontSize: UiResponsive.dimension_14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: UiResponsive.screenWidth! * 0.2,
            color: PrimaryColors.hint,
          ),
          SizedBox(height: UiResponsive.calculateHeight(16)),
          BuildDefaultText(
            text: 'لا يوجد زبائن',
            color: PrimaryColors.hint,
            fontSize: UiResponsive.dimension_18,
          ),
          SizedBox(height: UiResponsive.calculateHeight(8)),
          BuildDefaultText(
            text: 'اضغط على + لإضافة زبون جديد',
            color: PrimaryColors.hint,
            fontSize: UiResponsive.dimension_14,
          ),
        ],
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchHeaderDelegate({required this.child});

  @override
  double get minExtent => 70.0;

  @override
  double get maxExtent => 70.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) {
    return false;
  }
}
