class Category {
  final int id;
  final String name;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String slug;
  final String icon;
  final String description;
  final String descriptionUz;
  final String descriptionRu;
  final String descriptionEn;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.slug,
    required this.icon,
    required this.description,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'] ?? '',
    nameUz: json['name_uz'] ?? '',
    nameRu: json['name_ru'] ?? '',
    nameEn: json['name_en'] ?? '',
    slug: json['slug'] ?? '',
    icon: json['icon'] ?? '',
    description: json['description'] ?? '',
    descriptionUz: json['description_uz'] ?? '',
    descriptionRu: json['description_ru'] ?? '',
    descriptionEn: json['description_en'] ?? '',
    isActive: json['is_active'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_uz': nameUz,
    'name_ru': nameRu,
    'name_en': nameEn,
    'slug': slug,
    'icon': icon,
    'description': description,
    'description_uz': descriptionUz,
    'description_ru': descriptionRu,
    'description_en': descriptionEn,
    'is_active': isActive,
  };
  // Inside Category class

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

}
