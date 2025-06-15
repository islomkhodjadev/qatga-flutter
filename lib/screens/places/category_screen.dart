import 'package:flutter/material.dart';
import 'package:boyshub/models/places/category_model.dart';
import 'package:boyshub/models/places/place_model.dart';
import 'package:boyshub/screens/places/place_detail_screen.dart';
import 'package:boyshub/services/api_service.dart';
import 'dart:convert';
import 'package:boyshub/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:boyshub/widgets/places/place_card.dart';

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
  Position? _currentPosition;
  bool _isSortingByDistance = false;

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
  }

  Future<void> fetchPlaces({double? lat, double? lng}) async {
    setState(() => _isLoading = true);
    try {
      String url = 'places/places/?category_slug=${widget.category.slug}';

      // Add search param
      if (_searchQuery.trim().isNotEmpty) {
        url += '&search=${Uri.encodeQueryComponent(_searchQuery.trim())}';
      }

      // Add location parameters if provided and sorting by distance is enabled
      if (_isSortingByDistance && lat != null && lng != null) {
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final lang = Provider.of<LanguageProvider>(context, listen: false).lang;
        final bool? shouldEnable = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_getLocalizedText(lang, 'locationDisabledTitle')),
            content: Text(_getLocalizedText(lang, 'locationDisabledMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_getLocalizedText(lang, 'cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_getLocalizedText(lang, 'enable')),
              ),
            ],
          ),
        );
        if (shouldEnable ?? false) await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final lang = Provider.of<LanguageProvider>(context, listen: false).lang;
        final bool? openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_getLocalizedText(lang, 'permissionRequiredTitle')),
            content: Text(_getLocalizedText(lang, 'permissionRequiredMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_getLocalizedText(lang, 'cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_getLocalizedText(lang, 'settings')),
              ),
            ],
          ),
        );
        if (openSettings ?? false) await openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentPosition = position;
        _isSortingByDistance = true;
      });
      await fetchPlaces(lat: position.latitude, lng: position.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  void _toggleDistanceSorting() {
    setState(() {
      _isSortingByDistance = !_isSortingByDistance;
      if (_isSortingByDistance && _currentPosition != null) {
        fetchPlaces(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude);
      } else {
        fetchPlaces();
      }
    });
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
        'apply': 'Qo‘llash',
        'minPrice': 'Minimal narx',
        'maxPrice': 'Maksimal narx',
        'serviceType': 'Xizmat turi',
        'serviceName': 'Xizmat nomi',
        'clear': 'Tozalash',
        'searchHint': 'Nomi, manzili yoki xizmat bo‘yicha qidirish...',
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
          // IconButton(
          //   icon: const Icon(Icons.filter_alt), // <-- Forces black icon
          //   tooltip: _getLocalizedText(lang, 'filters'),
          //   onPressed: _showFilterDialog,
          // ),
          IconButton(
            icon: Image.asset(

              'assets/icons/filter.png',
              width: 24,
              height: 24,
              // Optional: apply color filter
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPosition != null)
            FloatingActionButton(
              heroTag: 'toggleDistance',
              onPressed: _toggleDistanceSorting,
              tooltip: _isSortingByDistance ? 'Disable distance sorting' : 'Enable distance sorting',
              child: Icon(
                _isSortingByDistance ? Icons.sort_by_alpha : Icons.near_me,
                color: _isSortingByDistance ? Colors.blue : null,
              ),
            ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'getLocation',
            onPressed: _isLocationLoading ? null : _getCurrentLocation,
            tooltip: 'Show nearby places',
            child: _isLocationLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
