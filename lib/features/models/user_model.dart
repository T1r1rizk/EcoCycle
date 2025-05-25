class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.points,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      points: map['points'],
    );
  }
}