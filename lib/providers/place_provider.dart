import 'package:flutter/material.dart';
import 'package:boyshub/models/places/place_model.dart';
import 'package:boyshub/services/api_service.dart';
import 'dart:convert';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('places/places/');
      print(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _places = data.map((json) => Place.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Failed to load places';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlace(Place place, String token) async {
    try {
      final response = await ApiService.post(
        'places/places/',
        place.toJson(),
        token: token,
      );
      if (response.statusCode == 201) {
        await fetchPlaces();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Place>> fetchPlacesByCategory(String slug) async {
    final response = await ApiService.get('places/places?category_slug=$slug');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Place.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }

}