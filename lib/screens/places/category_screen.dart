import 'package:flutter/material.dart';
import 'package:boyshub/models/places/category_model.dart';
import 'package:boyshub/models/places/place_model.dart';
import 'package:boyshub/screens/places/place_detail_screen.dart';
import 'package:boyshub/services/api_service.dart';
import 'dart:convert';
import 'dart:js' as js;
import 'package:boyshub/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:boyshub/widgets/places/place_card.dart';
import 'dart:async';
class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Place> _places = [];
  bool _isLoading = true;
  String? _error;
  bool _isLocationLoading = false;
  double? _currentLatitude;
  double? _currentLongitude;

  // FILTER STATE
  double? _filterMinPrice;
  double? _filterMaxPrice;
  String? _filterServicePricingType;
  String? _filterServiceName;

  // --- SEARCH STATE ---
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPlaces();
    _initializeTelegramWebApp();
  }

  void _initializeTelegramWebApp() {
    try {
      // Check if Telegram WebApp is available
      if (js.context.hasProperty('Telegram') &&
          js.context['Telegram'].hasProperty('WebApp')) {
        print('Telegram WebApp detected');

        // Check if LocationManager is available
        final webApp = js.context['Telegram']['WebApp'];
        if (webApp.hasProperty('LocationManager')) {
          print('LocationManager is available');
        } else {
          print('LocationManager is not available - using fallback');
        }
      } else {
        print('Not running in Telegram WebApp environment');
      }
    } catch (e) {
      print('Error initializing Telegram WebApp: $e');
    }
  }

  @override
  void didUpdateWidget(covariant CategoryDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.slug != widget.category.slug) {
      fetchPlaces();
    }
  }

  Future<void> fetchPlaces({double? lat, double? lng}) async {
    setState(() {
      _isLoading = true;
      _places = [];
      _error = null;
    });

    try {
      String url = 'places/places/?category_slug=${widget.category.slug}';

      // Add search param
      if (_searchQuery.trim().isNotEmpty) {
        url += '&search=${Uri.encodeQueryComponent(_searchQuery.trim())}';
      }

      // Add location parameters if provided
      if (lat != null && lng != null) {
        url += '&latitude=$lat&longitude=$lng&sort_by=distance';
      }

      // --- Add filters ---
      if (_filterMinPrice != null) url += '&service_min_price=${_filterMinPrice!.toStringAsFixed(2)}';
      if (_filterMaxPrice != null) url += '&service_max_price=${_filterMaxPrice!.toStringAsFixed(2)}';
      if (_filterServicePricingType != null && _filterServicePricingType!.isNotEmpty) url += '&service_pricing_type=${_filterServicePricingType!}';
      if (_filterServiceName != null && _filterServiceName!.isNotEmpty) url += '&service_name=${Uri.encodeQueryComponent(_filterServiceName!)}';

      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _places = data.map((json) => Place.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Joylarni olishda xatolik';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Internetda nosozlik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocationLoading) return;

    setState(() => _isLocationLoading = true);

    try {
      final lang = Provider.of<LanguageProvider>(context, listen: false).lang;

      // Try Telegram Mini App LocationManager first
      if (await _getTelegramLocation()) {
        if (_currentLatitude != null && _currentLongitude != null) {
          await fetchPlaces(lat: _currentLatitude, lng: _currentLongitude);
          return;
        }
      }

      // Fallback to Web Geolocation API
      if (await _getWebLocation()) {
        if (_currentLatitude != null && _currentLongitude != null) {
          await fetchPlaces(lat: _currentLatitude, lng: _currentLongitude);
          return;
        }
      }

      // If all methods fail, show error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedText(lang, 'locationError')),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<bool> _getTelegramLocation() async {
    try {
      // Check if we're in Telegram WebApp environment
      if (!js.context.hasProperty('Telegram') ||
          !js.context['Telegram'].hasProperty('WebApp')) {
        return false;
      }

      final webApp = js.context['Telegram']['WebApp'];

      // Check if LocationManager is available
      if (!webApp.hasProperty('LocationManager')) {
        print('LocationManager not available in this Telegram version');
        return false;
      }

      final locationManager = webApp['LocationManager'];

      // Check if location access is available
      if (!locationManager.callMethod('isLocationAvailable')) {
        print('Location is not available');
        return false;
      }

      // Request location
      return await _requestTelegramLocation(locationManager);

    } catch (e) {
      print('Error getting Telegram location: $e');
      return false;
    }
  }

  Future<bool> _requestTelegramLocation(dynamic locationManager) async {
    try {
      // Create a completer to handle the async callback
      final completer = Completer<bool>();

      // Set up callback for location result
      js.context['locationCallback'] = js.allowInterop((dynamic result) {
        try {
          if (result != null && result.hasProperty('latitude') && result.hasProperty('longitude')) {
            setState(() {
              _currentLatitude = result['latitude'].toDouble();
              _currentLongitude = result['longitude'].toDouble();
            });
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        } catch (e) {
          print('Error in location callback: $e');
          completer.complete(false);
        }
      });

      // Set up error callback
      js.context['locationErrorCallback'] = js.allowInterop((dynamic error) {
        print('Telegram location error: $error');
        completer.complete(false);
      });

      // Request location with callbacks
      locationManager.callMethod('getLocation', [
        js.context['locationCallback'],
        js.context['locationErrorCallback']
      ]);

      // Wait for result with timeout
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Telegram location request timed out');
          return false;
        },
      );

    } catch (e) {
      print('Error requesting Telegram location: $e');
      return false;
    }
  }

  Future<bool> _getWebLocation() async {
    try {
      // Use JavaScript navigator.geolocation as fallback
      if (!js.context['navigator'].hasProperty('geolocation')) {
        return false;
      }

      final completer = Completer<bool>();

      // Success callback
      js.context['webLocationSuccess'] = js.allowInterop((dynamic position) {
        try {
          final coords = position['coords'];
          setState(() {
            _currentLatitude = coords['latitude'].toDouble();
            _currentLongitude = coords['longitude'].toDouble();
          });
          completer.complete(true);
        } catch (e) {
          print('Error in web geolocation success: $e');
          completer.complete(false);
        }
      });

      // Error callback
      js.context['webLocationError'] = js.allowInterop((dynamic error) {
        print('Web geolocation error: ${error['message']}');
        completer.complete(false);
      });

      // Request location
      js.context['navigator']['geolocation'].callMethod('getCurrentPosition', [
        js.context['webLocationSuccess'],
        js.context['webLocationError'],
        js.JsObject.jsify({
          'enableHighAccuracy': true,
          'timeout': 10000,
          'maximumAge': 60000,
        })
      ]);

      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );

    } catch (e) {
      print('Error with web geolocation: $e');
      return false;
    }
  }

  String _getLocalizedText(String lang, String key) {
    final messages = {
    'uz': {
    'locationDisabledTitle': 'Joylashuv xizmati',
    'locationDisabledMessage': 'Joylashuv xizmati o\'chirilgan. Yoqilsinmi?',
    'permissionRequiredTitle': 'Ruxsat kerak',
    'permissionRequiredMessage': 'Ilova sozlamalaridan ruxsat bering',
    'cancel': 'Bekor qilish',
    'enable': 'Yoqish',
    'settings': 'Sozlamalar',
    'filters': 'Filterlar',
    'apply': "Qo'llash",
    'minPrice': 'Minimal narx',
    'maxPrice': 'Maksimal narx',
    'serviceType': 'Xizmat turi',
    'serviceName': 'Xizmat nomi',
    'clear': 'Tozalash',
    'searchHint': "Nomi, manzili yoki xizmat bo'yicha qidirish...",
    'locationError': 'Joylashuvni aniqlab bo\'lmadi. Telegram sozlamalarida ruxsat berilganligini tekshiring.',
    'locationSuccess': 'Joylashuv muvaffaqiyatli aniqlandi',
    },
    'ru': {
    'locationDisabledTitle': 'Служба геолокации',
    'locationDisabledMessage': 'Служба геолокации отключена. Включить?',
    'permissionRequiredTitle': 'Требуется разрешение',
    'permissionRequiredMessage': 'Разрешите в настройках приложения',
    'cancel': 'Отмена',
    'enable': 'Включить',
    'settings': 'Настройки',
    'filters': 'Фильтры',
    'apply': 'Применить',
    'minPrice': 'Мин. цена',
    'maxPrice': 'Макс. цена',
    'serviceType': 'Тип услуги',
    'serviceName': 'Название услуги',
    'clear': 'Очистить',
    'searchHint': 'Поиск по названию, адресу или услуге...',
    'locationError': 'Не удалось определить местоположение. Проверьте разрешения в настройках Telegram.',
    'locationSuccess': 'Местоположение успешно определено',
    },
    'en': {
    'locationDisabledTitle': 'Location Service',
    'locationDisabledMessage': 'Location service is disabled. Enable it?',
    'permissionRequiredTitle': 'Permission Required',
    'permissionRequiredMessage': 'Please allow permission from app settings',
    'cancel': 'Cancel',
    'enable': 'Enable',
    'settings': 'Settings',
    'filters': 'Filters',
    'apply': 'Apply',
    'minPrice': 'Min Price',
    'maxPrice': 'Max Price',
    'serviceType': 'Service Type',
    'serviceName': 'Service Name',
    'clear': 'Clear',
    'searchHint': 'Search by name, address, or service...',
    'locationError': 'Could not determine location. Check permissions in Telegram settings.',
    'locationSuccess': 'Location successfully determined',
    },
    };
    return messages[lang]?[key] ?? messages['en']![key] ?? key;
  }

  List<DropdownMenuItem<String>> _pricingTypes(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).lang;
    final types = {
      "uz": {
        "per_hour": "Soatiga",
        "per_person": "Har bir odam uchun",
        "per_person_per_hour": "Har bir odam uchun soatiga",
        "free": "Bepul"
      },
      "ru": {
        "per_hour": "Почасово",
        "per_person": "За человека",
        "per_person_per_hour": "За человека в час",
        "free": "Бесплатно"
      },
      "en": {
        "per_hour": "Per Hour",
        "per_person": "Per Person",
        "per_person_per_hour": "Per Person Per Hour",
        "free": "Free"
      }
    };

    return types[lang]!.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList();
  }

  void _showFilterDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false).lang;
    final TextEditingController minPriceController =
    TextEditingController(text: _filterMinPrice?.toString() ?? '');
    final TextEditingController maxPriceController =
    TextEditingController(text: _filterMaxPrice?.toString() ?? '');
    final TextEditingController serviceNameController =
    TextEditingController(text: _filterServiceName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String? selectedPricingType = _filterServicePricingType;
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getLocalizedText(lang, 'filters'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  minPriceController.clear();
                                  maxPriceController.clear();
                                  serviceNameController.clear();
                                  selectedPricingType = null;
                                });
                              },
                              child: Text(_getLocalizedText(lang, 'clear')),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Min price
                    TextField(
                      controller: minPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _getLocalizedText(lang, 'minPrice'),
                      ),
                    ),
                    // Max price
                    const SizedBox(height: 12),
                    TextField(
                      controller: maxPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _getLocalizedText(lang, 'maxPrice'),
                      ),
                    ),
                    // Service Type
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPricingType,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('- ${_getLocalizedText(lang, 'serviceType')} -'),
                        ),
                        ..._pricingTypes(context)
                      ],
                      onChanged: (val) => setModalState(() => selectedPricingType = val),
                      decoration: InputDecoration(
                        labelText: _getLocalizedText(lang, 'serviceType'),
                      ),
                    ),
                    // Service Name
                    const SizedBox(height: 12),
                    TextField(
                      controller: serviceNameController,
                      decoration: InputDecoration(
                        labelText: _getLocalizedText(lang, 'serviceName'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterMinPrice = double.tryParse(minPriceController.text);
                          _filterMaxPrice = double.tryParse(maxPriceController.text);
                          _filterServicePricingType = selectedPricingType;
                          _filterServiceName = serviceNameController.text.isEmpty
                              ? null
                              : serviceNameController.text;
                        });
                        fetchPlaces();
                        Navigator.pop(context);
                      },
                      child: Text(_getLocalizedText(lang, 'apply')),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).lang;

    final category = widget.category;
    TextStyle sectionStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.blueAccent,
      letterSpacing: 1.2,
    );

    final sectionTitles = {
      'uz': "JOYNI TANLANG",
      'ru': "ВЫБЕРИТЕ МЕСТО",
      'en': "CHOOSE A PLACE",
    };
    final emptyTexts = {
      'uz': "Bu kategoriyada joy topilmadi",
      'ru': "В этой категории ничего не найдено",
      'en': "No places found in this category",
    };

    return Scaffold(
      appBar: MyAppBar(
        title: category.getName(lang),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/filter.png',
              width: 24,
              height: 24,
            ),
            tooltip: _getLocalizedText(lang, 'filters'),
            onPressed: _showFilterDialog,
          )
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                setState(() {
                  _searchQuery = val;
                });
                fetchPlaces();
              },
              onChanged: (val) {
                // Optional: search as you type (debounce if needed)
              },
              decoration: InputDecoration(
                hintText: _getLocalizedText(lang, 'searchHint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    fetchPlaces();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _places.isEmpty
                ? Center(child: Text(emptyTexts[lang] ?? emptyTexts['uz']!))
                : ListView(
              children: [
                if (category.icon.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    child: Image.network(
                      category.icon,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.getName(lang),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(category.getDescription(lang)),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    sectionTitles[lang] ?? sectionTitles['uz']!,
                    style: sectionStyle,
                  ),
                ),
                const SizedBox(height: 8),
                ..._places.map(
                      (place) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: PlaceCard(
                      place: place,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailScreen(place: place),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLocationLoading ? null : _getCurrentLocation,
        tooltip: 'Show nearest places',
        child: _isLocationLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.near_me),
      ),
    );
  }
}