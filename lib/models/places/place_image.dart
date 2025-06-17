class PlaceImage {
  final int id;
  final String url;
  final bool is_primary;
  PlaceImage({required this.id, required this.url, required this.is_primary});

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'],
      url: json['image'],
        is_primary: json['is_primary']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'is_primary': is_primary
  };
}
