import 'package:crmapp/src/common/models/expencse_model.dart';
import 'package:equatable/equatable.dart';

abstract class PersionalExpensesEvent extends Equatable {
  const PersionalExpensesEvent();

  @override
  List<Object> get props => [];
}

class LoadPersionalExpenses extends PersionalExpensesEvent {}

class AddPersionalExpenses extends PersionalExpensesEvent {
  final ExpencseModel expense;
  const AddPersionalExpenses(this.expense);

  @override
  List<Object> get props => [expense];
}
