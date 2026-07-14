class RideModel {
  final int id;
  final int driverId;
  final String patientName;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String hospitalName;
  final double hospitalLat;
  final double hospitalLng;
  final String status;

  RideModel({
    required this.id,
    required this.driverId,
    required this.patientName,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.hospitalName,
    required this.hospitalLat,
    required this.hospitalLng,
    required this.status,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json["id"],
      driverId: json["driver_id"],
      patientName: json["patient_name"],
      pickupAddress: json["pickup_address"],
      pickupLat: (json["pickup_lat"] as num).toDouble(),
      pickupLng: (json["pickup_lng"] as num).toDouble(),
      hospitalName: json["hospital_name"],
      hospitalLat: (json["hospital_lat"] as num).toDouble(),
      hospitalLng: (json["hospital_lng"] as num).toDouble(),
      status: json["status"],
    );
  }
}