import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/index.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AuthRepository _authRepository;
  final ApiService _apiService = ApiService();

  DashboardBloc(this._authRepository) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final stats = await _apiService.getDashboardStats(period: event.period);
      final chartData = await _apiService.getSalesChart(days: 7);
      final topProducts = await _apiService.getTopProducts(limit: 5);
      final notifications = await _apiService.getNotifications(
        unreadOnly: true,
        limit: 10,
      );

      emit(DashboardLoaded(
        stats: stats,
        chartData: chartData,
        topProducts: topProducts,
        notifications: notifications,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }
    
    try {
      final stats = await _apiService.getDashboardStats(period: 'month');
      final chartData = await _apiService.getSalesChart(days: 7);
      final topProducts = await _apiService.getTopProducts(limit: 5);
      final notifications = await _apiService.getNotifications(
        unreadOnly: true,
        limit: 10,
      );

      emit(DashboardLoaded(
        stats: stats,
        chartData: chartData,
        topProducts: topProducts,
        notifications: notifications,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
