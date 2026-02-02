part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class CustomerLoadListRequested extends CustomerEvent {
  final int? page;
  final int? limit;
  final String? search;
  final String? type;
  final String? status;

  const CustomerLoadListRequested({
    this.page,
    this.limit,
    this.search,
    this.type,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, search, type, status];
}

class CustomerLoadDetailRequested extends CustomerEvent {
  final String id;

  const CustomerLoadDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CustomerCreateRequested extends CustomerEvent {
  final Map<String, dynamic> data;

  const CustomerCreateRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class CustomerUpdateRequested extends CustomerEvent {
  final String id;
  final Map<String, dynamic> data;

  const CustomerUpdateRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class CustomerDeleteRequested extends CustomerEvent {
  final String id;

  const CustomerDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CustomerSearchRequested extends CustomerEvent {
  final String query;

  const CustomerSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}
