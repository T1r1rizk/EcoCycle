class Address {
  String? objectId;
  String name;
  String email;
  String phone;
  String address;
  String zipCode;
  String city;
  String country;
  bool isDefault;

  Address({
    this.objectId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.zipCode,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  factory Address.fromParse(Map<String, dynamic> json) {
    return Address(
      objectId: json['objectId'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      zipCode: json['zipCode'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toParse() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'isDefault': isDefault,
    };
  }

  static Future<List<Address>> fromJson(Map<String, dynamic> item) async {
    // Example implementation: Parse the JSON and return a list of Address objects
    if (item['addresses'] != null && item['addresses'] is List) {
      return (item['addresses'] as List)
          .map((address) => Address.fromParse(address))
          .toList();
    } else {
      // Throw an exception if the input is invalid
      throw Exception('Invalid JSON format for addresses');
    }
  }
}