class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final int mileage;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.mileage,
  });

  // Constructeur de fabrique pour créer un objet Car à partir d'un Map
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year'] ?? '') ?? 0,
      color: json['color'] ?? '',
      mileage: json['mileage'] is int ? json['mileage'] : int.tryParse(json['mileage'] ?? '') ?? 0,
    );
  }
}

class MaintenanceRecord {
  final String type;
  final String date;
  final String description;
  final double cost;

  MaintenanceRecord({
    required this.type,
    required this.date,
    required this.description,
    required this.cost,
  });

  // Constructeur de fabrique pour créer un objet MaintenanceRecord à partir d'un Map
  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] is double 
        ? json['cost'] 
        : double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}