import 'package:balawi_app/core/network/api_response.dart';
import 'package:balawi_app/core/util/ui_responsive.dart';
import 'package:balawi_app/features/customers/data/models/customer_model.dart';
import 'package:balawi_app/features/customers/data/models/letter_model.dart';
import 'package:balawi_app/features/customers/data/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService();

  TextEditingController searchTextController = TextEditingController();

  // Loading states
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;
  String? errorMessage;

  // Customer data
  List<CustomerModel> customers = [];
  PaginationModel? pagination;

  // Filter state
  String? selectedLetter;
  String? searchQuery;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  /// Fetch customers from API
  Future<void> fetchCustomers({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (isLoading || isLoadingMore) return;

    if (loadMore && pagination != null) {
      if (pagination!.currentPage >= pagination!.totalPages) return;
      isLoadingMore = true;
    } else {
      isLoading = true;
      if (refresh) {
        customers = [];
        pagination = null;
      }
    }
    errorMessage = null;
    update();

    final int page = loadMore && pagination != null
        ? pagination!.currentPage + 1
        : 1;

    final response = await _customerService.getAllCustomers(
      search: searchQuery,
      letter: selectedLetter,
      page: page,
      limit: 10,
    );

    if (response.success && response.data != null) {
      if (loadMore) {
        customers.addAll(response.data!.customers);
      } else {
        customers = response.data!.customers;
      }
      pagination = response.data!.pagination;
    } else {
      errorMessage = response.message;
    }

    isLoading = false;
    isLoadingMore = false;
    update();
  }

  /// Search customers
  Future<void> search() async {
    searchQuery = searchTextController.text.trim();
    await fetchCustomers(refresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    searchTextController.clear();
    searchQuery = null;
    await fetchCustomers(refresh: true);
  }

  /// Toggle letter selection (without applying filter)
  void toggleLetterSelection(String? letter) {
    if (letter == null) return;

    if (selectedLetter == letter) {
      selectedLetter = null;
    } else {
      selectedLetter = letter;
    }

    // Update selection state in listOfLetters
    for (var l in listOfLetters) {
      l.selected = l.id == selectedLetter;
    }
    update();
  }

  /// Apply the selected letters filter
  Future<void> applyLetterFilter() async {
    await fetchCustomers(refresh: true);
  }

  /// Clear all selected letters
  void clearAllLetters() {
    selectedLetter = null;
    for (var l in listOfLetters) {
      l.selected = false;
    }
    update();
  }

  /// Create a new customer
  Future<bool> createCustomer(CustomerModel customer) async {
    isSubmitting = true;
    errorMessage = null;
    update();

    final response = await _customerService.createCustomer(customer);

    isSubmitting = false;
    if (response.success && response.data != null) {
      // Add to beginning of list
      customers.insert(0, response.data!);
      update();
      return true;
    } else {
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer(String id, CustomerModel customer) async {
    isSubmitting = true;
    errorMessage = null;
    update();

    final response = await _customerService.updateCustomer(id, customer);

    isSubmitting = false;
    if (response.success && response.data != null) {
      // Update in list
      final index = customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        customers[index] = response.data!;
      }
      update();
      return true;
    } else {
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Delete a customer
  Future<bool> deleteCustomer(String id) async {
    isSubmitting = true;
    errorMessage = null;

    // Optimistic update: remove from list immediately to avoid Dismissible error
    final customerIndex = customers.indexWhere((c) => c.id == id);
    CustomerModel? removedCustomer;
    if (customerIndex != -1) {
      removedCustomer = customers[customerIndex];
      customers.removeAt(customerIndex);
    }
    update();

    final response = await _customerService.deleteCustomer(id);

    isSubmitting = false;
    if (response.success) {
      update();
      return true;
    } else {
      // Restore customer if deletion failed
      if (removedCustomer != null && customerIndex != -1) {
        customers.insert(customerIndex, removedCustomer);
      }
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    final response = await _customerService.getCustomerById(id);
    if (response.success && response.data != null) {
      return response.data;
    }
    errorMessage = response.message;
    return null;
  }

  List<LetterModel> listOfLetters = [
    LetterModel(id: 'ا', title: 'ا', selected: false),
    LetterModel(id: 'ب', title: 'ب', selected: false),
    LetterModel(id: 'ت', title: 'ت', selected: false),
    LetterModel(id: 'ث', title: 'ث', selected: false),
    LetterModel(id: 'ج', title: 'ج', selected: false),
    LetterModel(id: 'ح', title: 'ح', selected: false),
    LetterModel(id: 'خ', title: 'خ', selected: false),
    LetterModel(id: 'د', title: 'د', selected: false),
    LetterModel(id: 'ذ', title: 'ذ', selected: false),
    LetterModel(id: 'ر', title: 'ر', selected: false),
    LetterModel(id: 'ز', title: 'ز', selected: false),
    LetterModel(id: 'س', title: 'س', selected: false),
    LetterModel(id: 'ش', title: 'ش', selected: false),
    LetterModel(id: 'ص', title: 'ص', selected: false),
    LetterModel(id: 'ض', title: 'ض', selected: false),
    LetterModel(id: 'ط', title: 'ط', selected: false),
    LetterModel(id: 'ظ', title: 'ظ', selected: false),
    LetterModel(id: 'ع', title: 'ع', selected: false),
    LetterModel(id: 'غ', title: 'غ', selected: false),
    LetterModel(id: 'ف', title: 'ف', selected: false),
    LetterModel(id: 'ق', title: 'ق', selected: false),
    LetterModel(id: 'ك', title: 'ك', selected: false),
    LetterModel(id: 'ل', title: 'ل', selected: false),
    LetterModel(id: 'م', title: 'م', selected: false),
    LetterModel(id: 'ن', title: 'ن', selected: false),
    LetterModel(id: 'هـ', title: 'هـ', selected: false),
    LetterModel(id: 'و', title: 'و', selected: false),
    LetterModel(id: 'ي', title: 'ي', selected: false),
  ];

  List<LetterModel> getList() {
    if (showAllReadingLevel) {
      return listOfLetters;
    } else {
      return listOfLetters.take(UiResponsive.isTablet() ? 10 : 6).toList();
    }
  }

  selectLetters(String id) {
    toggleLetterSelection(id);
  }

  bool showAllReadingLevel = false;
  changeShowAllReadingLevel() {
    showAllReadingLevel = !showAllReadingLevel;
    update();
  }
}
