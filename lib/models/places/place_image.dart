class PlaceImage {
  final int id;
  final String url;

  PlaceImage({required this.id, required this.url});

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'],
      url: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
  };
}
