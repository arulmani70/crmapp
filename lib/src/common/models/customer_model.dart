import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool status;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? status,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "status": status,
  };

  factory CustomerModel.empty() {
    return CustomerModel(id: '', name: '', email: '', phone: '', status: false);
  }

  @override
  List<Object?> get props => [id, name, email, phone, status];
}
