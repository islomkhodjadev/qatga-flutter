class Service {
  final int id;
  final String name;
  final double price;

  Service({required this.id, required this.name, required this.price});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
  };
}
