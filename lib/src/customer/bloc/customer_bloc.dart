import 'package:crmapp/src/customer/repo/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crmapp/src/common/models/customer_model.dart';
import 'package:logger/logger.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  final log = Logger();
  CustomerBloc({required CustomerRepository repository})
    : _repository = repository,
      super(CustomerState.initial) {
    on<InitializeCustomer>(_onInitCustomers);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<AddCustomer>(_onAddCustomers);
    on<ChangeCustomerFormValue>(_onChangeForm);
  }

  Future<void> _onChangeForm(
    ChangeCustomerFormValue event,
    Emitter<CustomerState> emit,
  ) async {
    log.d("DeviceRequestBloc::_onChangeFormValueToState::${event.formValue}");

    final formValue = state.formValue?.copyWith(
      name: event.formValue['name'],
      email: event.formValue['email'],
      phone: event.formValue['phone'],
      status: event.formValue['status'],
    );

    emit(
      state.copyWith(
        customerStatus: CustomerStatus.changed,
        formValue: formValue,
      ),
    );
  }

  Future<void> _onInitCustomers(
    InitializeCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(customerStatus: CustomerStatus.loading));

    final customers = await _repository.getCustomerList();

    emit(
      state.copyWith(
        customerStatus: CustomerStatus.loaded,
        customerModel: customers,
      ),
    );
  }

  Future<void> _onAddCustomers(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(customerStatus: CustomerStatus.loading));
    final form = state.formValue!.copyWith();

    await _repository.addCustomer(form);
    final customers = await _repository.getCustomerList();
    emit(
      state.copyWith(
        customerStatus: CustomerStatus.success,
        customerModel: customers,
      ),
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(customerStatus: CustomerStatus.loading));

    await _repository.deleteCustomer(event.id);
    final customers = await _repository.getCustomerList();
    emit(
      state.copyWith(
        customerStatus: CustomerStatus.deleted,
        customerModel: customers,
      ),
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(customerStatus: CustomerStatus.loading));

    await _repository.updateCustomer(event.id, event.customer);
    final customers = await _repository.getCustomerList();
    emit(
      state.copyWith(
        customerStatus: CustomerStatus.updated,
        customerModel: customers,
      ),
    );
  }
}
