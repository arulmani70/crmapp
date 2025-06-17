import 'package:crmapp/src/common/models/expencse_model.dart';
import 'package:equatable/equatable.dart';

enum PersionalExpensesStatus { initial, loading, success, failure }

class PersionalExpensesState extends Equatable {
  final PersionalExpensesStatus status;
  final List<ExpencseModel> expenses;
  final String? message;

  const PersionalExpensesState({
    required this.status,
    required this.expenses,
    this.message,
  });

  static const initial = PersionalExpensesState(
    status: PersionalExpensesStatus.initial,
    expenses: [],
    message: "",
  );

  PersionalExpensesState copyWith({
    PersionalExpensesStatus Function()? status,
    List<ExpencseModel> Function()? expenses,
    String Function()? message,
  }) {
    return PersionalExpensesState(
      status: status != null ? status() : this.status,
      expenses: expenses != null ? expenses() : this.expenses,
      message: message != null ? message() : this.message,
    );
  }

  @override
  List<Object> get props => [status, expenses, message ?? ''];
}
