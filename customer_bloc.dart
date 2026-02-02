import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../repositories/customer_repository.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerBloc({required CustomerRepository customerRepository})
      : _customerRepository = customerRepository,
        super(CustomerInitial()) {
    on<CustomerLoadListRequested>(_onLoadListRequested);
    on<CustomerLoadDetailRequested>(_onLoadDetailRequested);
    on<CustomerCreateRequested>(_onCreateRequested);
    on<CustomerUpdateRequested>(_onUpdateRequested);
    on<CustomerDeleteRequested>(_onDeleteRequested);
    on<CustomerSearchRequested>(_onSearchRequested);
  }

  Future<void> _onLoadListRequested(
    CustomerLoadListRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.getCustomers(
        page: event.page,
        limit: event.limit,
        search: event.search,
        type: event.type,
        status: event.status,
      );
      emit(CustomerListLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadDetailRequested(
    CustomerLoadDetailRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customer = await _customerRepository.getCustomer(event.id);
      emit(CustomerDetailLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    CustomerCreateRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customer = await _customerRepository.createCustomer(event.data);
      emit(CustomerCreated(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    CustomerUpdateRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customer = await _customerRepository.updateCustomer(
        event.id,
        event.data,
      );
      emit(CustomerUpdated(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    CustomerDeleteRequested event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.deleteCustomer(event.id);
      emit(CustomerDeleted(event.id));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    CustomerSearchRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.getCustomers(
        search: event.query,
        limit: 20,
      );
      emit(CustomerListLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
