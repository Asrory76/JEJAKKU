class Vehicle {
  final int? id;
  final String name;
  final String plate;
  final bool isMotor;
  final String status;
  final Map<String, dynamic>? lastPosition;

  const Vehicle({
    this.id,
    required this.name,
    required this.plate,
    required this.isMotor,
    this.status = 'connected',
    this.lastPosition,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      isMotor: json['isMotor'] == true || json['is_motor'] == 1,
      status: json['status'] as String? ?? 'connected',
      lastPosition: json['lastPosition'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      'isMotor': isMotor,
      'status': status,
      'lastPosition': lastPosition,
    };
  }
}
