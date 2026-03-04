import 'package:balawi_app/core/resources/color.dart';
import 'package:balawi_app/core/resources/images.dart';
import 'package:balawi_app/core/resources/language_keys.dart';
import 'package:balawi_app/core/util/snackbar_helper.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/core/widgets/build_default_text.dart';
import 'package:balawi_app/features/deliveries/deliveries_controller.dart';
import 'package:balawi_app/features/deliveries/pages/work_order_details_page.dart';
import 'package:balawi_app/features/deliveries/widgets/work_order_filter_bottom_sheet.dart';
import 'package:balawi_app/features/deliveries/widgets/work_order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  late ScrollController _scrollController;
  late DeliveriesController deliveriesController;

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
      deliveriesController.fetchWorkOrders(loadMore: true);
    }
  }

  Future<void> _handleDelete(String? orderId) async {
    if (orderId == null) return;

    final success = await deliveriesController.deleteWorkOrder(orderId);
    if (success) {
      SnackbarHelper.showSuccess(LanguageKeys.workOrderDeletedSuccessfully);
    } else {
      SnackbarHelper.showError(
        deliveriesController.errorMessage ?? LanguageKeys.deleteWorkOrderFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    deliveriesController = Get.put(DeliveriesController());
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<DeliveriesController>(
          builder: (_) {
            return RefreshIndicator(
              onRefresh: () async {
                await deliveriesController.fetchWorkOrders(refresh: true);
                await deliveriesController.fetchStatistics();
              },
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
                            text: LanguageKeys.workOrders,
                            color: PrimaryColors.black,
                            fontSize:
                                UiResponsive.dimension_15 +
                                UiResponsive.dimension_15,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          //SizedBox(height: UiResponsive.calculateHeight(20.0)),
                          _buildStatistics(),
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
                    if (deliveriesController.isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PrimaryColors.blue,
                          ),
                        ),
                      )
                    // Error state
                    else if (deliveriesController.errorMessage != null &&
                        deliveriesController.workOrders.isEmpty)
                      SliverFillRemaining(child: _buildErrorWidget())
                    // Empty state
                    else if (deliveriesController.workOrders.isEmpty)
                      SliverFillRemaining(child: _buildEmptyWidget())
                    // Work orders list
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index ==
                                deliveriesController.workOrders.length) {
                              if (deliveriesController.isLoadingMore) {
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
                              return SizedBox(
                                height: UiResponsive.calculateHeight(75.0),
                              );
                            }

                            final workOrder =
                                deliveriesController.workOrders[index];
                            return WorkOrderItem(
                              workOrder: workOrder,
                              onDelete: () => _handleDelete(workOrder.id),
                            );
                          },
                          childCount:
                              deliveriesController.workOrders.length + 1,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'deliveries_fab',
        onPressed: () {
          Get.to(const WorkOrderDetailsPage(isEditing: false));
        },
        backgroundColor: PrimaryColors.blue,
        child: const Icon(Icons.add, color: PrimaryColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatistics() {
    if (deliveriesController.statistics == null) {
      return const SizedBox.shrink();
    }

    final stats = deliveriesController.statistics!;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: PrimaryColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PrimaryColors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                LanguageKeys.totalOrders,
                stats.total.toString(),
                Icons.assignment,
                PrimaryColors.blue,
              ),
              _buildStatItem(
                LanguageKeys.readyOrders,
                stats.ready.toString(),
                Icons.check_circle_outline,
                PrimaryColors.blue,
              ),
              _buildStatItem(
                LanguageKeys.deliveredOrders,
                stats.delivered.toString(),
                Icons.check_circle,
                PrimaryColors.success,
              ),
            ],
          ),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          Divider(color: PrimaryColors.grey),
          SizedBox(height: UiResponsive.calculateHeight(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                LanguageKeys.totalRevenue,
                '${stats.totalRevenue}',
                Icons.monetization_on_outlined,
                PrimaryColors.black,
              ),
              _buildStatItem(
                LanguageKeys.unpaidOrders,
                stats.unpaid.toString(),
                Icons.warning_amber_rounded,
                PrimaryColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: UiResponsive.screenWidth! * 0.9,
            child: TextFormField(
              controller: deliveriesController.searchTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: PrimaryColors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: PrimaryColors.white,
                hintText: 'ابحث عن اسم الزبون',
                hintStyle: TextStyle(
                  fontSize: UiResponsive.dimension_14,
                  color: const Color(0xFF9A9DA3),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'IBMPlexSansArabic',
                ),
                suffixIcon: GestureDetector(
                  onTap: () => deliveriesController.search(),
                  child: SvgPicture.asset(
                    PrimaryImages.search,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                prefixIcon:
                    deliveriesController.searchQuery != null &&
                        deliveriesController.searchQuery!.isNotEmpty
                    ? GestureDetector(
                        onTap: () => deliveriesController.clearSearch(),
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
                deliveriesController.search();
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
                return const WorkOrderFilterBottomSheet();
              },
            );
          },
          child: Container(
            width: UiResponsive.calculateWidth(50),
            height: UiResponsive.calculateHeight(55),
            decoration: BoxDecoration(
              color: deliveriesController.hasActiveFilters
                  ? PrimaryColors.blue
                  : PrimaryColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list,
                  color: PrimaryColors.white,
                  size: UiResponsive.dimension_24,
                ),
                if (deliveriesController.hasActiveFilters)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: PrimaryColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: UiResponsive.dimension_24),
        SizedBox(height: UiResponsive.calculateHeight(4)),
        BuildDefaultText(
          text: value,
          color: color,
          fontSize: UiResponsive.dimension_18,
          fontWeight: FontWeight.bold,
        ),
        BuildDefaultText(
          text: label,
          color: PrimaryColors.hint,
          fontSize: UiResponsive.dimension_11,
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
            text: deliveriesController.errorMessage ?? 'حدث خطأ',
            color: PrimaryColors.black,
            fontSize: UiResponsive.dimension_16,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UiResponsive.calculateHeight(16)),
          ElevatedButton(
            onPressed: () =>
                deliveriesController.fetchWorkOrders(refresh: true),
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
            Icons.assignment_outlined,
            size: UiResponsive.screenWidth! * 0.2,
            color: PrimaryColors.hint,
          ),
          SizedBox(height: UiResponsive.calculateHeight(16)),
          BuildDefaultText(
            text: 'لا يوجد طلبات',
            color: PrimaryColors.hint,
            fontSize: UiResponsive.dimension_18,
          ),
          SizedBox(height: UiResponsive.calculateHeight(8)),
          BuildDefaultText(
            text: 'اضغط على + لإضافة طلب جديد',
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
