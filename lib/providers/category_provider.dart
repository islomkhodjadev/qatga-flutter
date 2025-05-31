import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:boyshub/models/places/category_model.dart';
import "package:boyshub/services/api_service.dart";

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('places/categories/');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _categories = data.map((json) => Category.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Failed to load categories';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
