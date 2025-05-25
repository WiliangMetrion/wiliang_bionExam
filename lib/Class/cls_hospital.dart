import 'dart:math';

class Hospital {
  final String name;
  final String address;
  final String region;
  final String phone;
  final String province;
  final String? imagePath;

  Hospital(
    this.name,
    this.address,
    this.region,
    this.phone,
    this.province,
    this.imagePath,
  );

  factory Hospital.fromJson(Map<String, dynamic> json) {
    Random random = Random();
    int randomPict = random.nextInt(10) + 1;
    return Hospital(
      json['name'] ?? '',
      json['address'] ?? '',
      json['region'] ?? '',
      json['phone'] ?? '',
      json['province'] ?? '',
      'images/$randomPict.jpg',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'region': region,
      'phone': phone,
      'province': province,
    };
  }
}
