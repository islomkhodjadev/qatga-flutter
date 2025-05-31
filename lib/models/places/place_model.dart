import 'place_image.dart';
import 'amenity.dart';
import 'service.dart';
import 'category_model.dart';  // Import your Category model
class Place {
  final int id;
  final String name;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String description;
  final String descriptionUz;
  final String descriptionRu;
  final String descriptionEn;
  final String address;
  final String address_url;
  final String addressUz;
  final String addressRu;
  final String addressEn;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final String holidays;
  final String phoneNumber;
  final String? telegram;
  final String? instagram;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int owner;
  final List<PlaceImage> images;
  final List<Amenity> amenities;
  final List<Service> services;
  final Category? category;

  Place({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.description,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.address,
    required this.address_url,
    required this.addressUz,
    required this.addressRu,
    required this.addressEn,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.holidays,
    required this.phoneNumber,
    this.telegram,
    this.instagram,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
    required this.owner,
    required this.images,
    required this.amenities,
    required this.services,
    this.category,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      descriptionUz: json['description_uz'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      address: json['address'] ?? '',
      address_url: json['address_url'] ?? '',
      addressUz: json['address_uz'] ?? '',
      addressRu: json['address_ru'] ?? '',
      addressEn: json['address_en'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      holidays: json['holidays'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      telegram: (json['telegram'] == null || json['telegram'] == '') ? null : json['telegram'],
      instagram: (json['instagram'] == null || json['instagram'] == '') ? null : json['instagram'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      owner: json['owner'] ?? 0,
      images: json['images'] != null
          ? List<PlaceImage>.from(json['images'].map((x) => PlaceImage.fromJson(x)))
          : [],
      amenities: json['amenities'] != null
          ? List<Amenity>.from(json['amenities'].map((x) => Amenity.fromJson(x)))
          : [],
      services: json['services'] != null
          ? List<Service>.from(json['services'].map((x) => Service.fromJson(x)))
          : [],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_uz': nameUz,
    'name_ru': nameRu,
    'name_en': nameEn,
    'description': description,
    'description_uz': descriptionUz,
    'description_ru': descriptionRu,
    'description_en': descriptionEn,
    'address': address,
    'address_url': address_url,
    'address_uz': addressUz,
    'address_ru': addressRu,
    'address_en': addressEn,
    'latitude': latitude,
    'longitude': longitude,
    'opening_time': openingTime,
    'closing_time': closingTime,
    'holidays': holidays,
    'phone_number': phoneNumber,
    'telegram': telegram,
    'instagram': instagram,
    'is_verified': isVerified,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'owner': owner,
    'images': images.map((x) => x.toJson()).toList(),
    'amenities': amenities.map((x) => x.toJson()).toList(),
    'services': services.map((x) => x.toJson()).toList(),
    'category': category?.toJson(),
  };
// Inside Place class

  String getName(String lang) {
    switch (lang) {
      case 'uz':
        return nameUz.isNotEmpty ? nameUz : name;
      case 'ru':
        return nameRu.isNotEmpty ? nameRu : name;
      case 'en':
        return nameEn.isNotEmpty ? nameEn : name;
      default:
        return name;
    }
  }

  String getDescription(String lang) {
    switch (lang) {
      case 'uz':
        return descriptionUz.isNotEmpty ? descriptionUz : description;
      case 'ru':
        return descriptionRu.isNotEmpty ? descriptionRu : description;
      case 'en':
        return descriptionEn.isNotEmpty ? descriptionEn : description;
      default:
        return description;
    }
  }

  String getAddress(String lang) {
    switch (lang) {
      case 'uz':
        return addressUz.isNotEmpty ? addressUz : address;
      case 'ru':
        return addressRu.isNotEmpty ? addressRu : address;
      case 'en':
        return addressEn.isNotEmpty ? addressEn : address;
      default:
        return address;
    }
  }



}
