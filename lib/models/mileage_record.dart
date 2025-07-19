class MileageRecord {
  final int? id;
  final String vehicleType;
  final double distance;
  final double fuelUsed;
  final double mileage;
  final DateTime date;

  MileageRecord({
    this.id,
    required this.vehicleType,
    required this.distance,
    required this.fuelUsed,
    required this.mileage,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'distance': distance,
      'fuelUsed': fuelUsed,
      'mileage': mileage,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory MileageRecord.fromMap(Map<String, dynamic> map) {
    return MileageRecord(
      id: map['id'],
      vehicleType: map['vehicleType'],
      distance: map['distance'],
      fuelUsed: map['fuelUsed'],
      mileage: map['mileage'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}
