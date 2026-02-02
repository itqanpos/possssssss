part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final String? period;

  const DashboardLoadRequested({this.period});

  @override
  List<Object?> get props => [period];
}

class DashboardRefreshRequested extends DashboardEvent {}
