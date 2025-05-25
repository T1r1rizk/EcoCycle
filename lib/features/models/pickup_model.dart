class PickupModel {
  final String id;
  final String userId;
  final String address;
  final String status; // "pending", "completed"
  final DateTime requestDate;
  final int pointsEarned;

  PickupModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.status,
    required this.requestDate,
    required this.pointsEarned,
  });

  factory PickupModel.fromMap(Map<String, dynamic> map) {
    return PickupModel(
      id: map['id'],
      userId: map['userId'],
      address: map['address'],
      status: map['status'],
      requestDate: DateTime.parse(map['requestDate']),
      pointsEarned: map['pointsEarned'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'pointsEarned': pointsEarned,
    };
  }
}