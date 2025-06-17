import 'package:equatable/equatable.dart';

class ExpencseModel extends Equatable {
  final String id;
  final String name;
  final String title;
  final String amount;
  final String date;

  const ExpencseModel({
    required this.id,
    required this.name,
    required this.title,
    required this.amount,
    required this.date,
  });

  ExpencseModel copyWith({
    String? id,
    String? name,
    String? title,
    String? amount,
    String? date,
  }) {
    return ExpencseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  factory ExpencseModel.fromJson(Map<String, dynamic> json) {
    return ExpencseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      amount: json['amount'] ?? '',
      date: json['date'] ?? '',
    );
  }

  factory ExpencseModel.empty() {
    return ExpencseModel(id: '', name: '', title: '', amount: '', date: '');
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "title": title,
    "amount": amount,
    "date": date,
  };

  @override
  List<Object> get props => [id, name, title, amount, date];
}
