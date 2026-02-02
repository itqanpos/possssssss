part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<SalesChartData> chartData;
  final List<TopProduct> topProducts;
  final List<NotificationModel> notifications;
  final bool isRefreshing;

  const DashboardLoaded({
    required this.stats,
    required this.chartData,
    required this.topProducts,
    required this.notifications,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<SalesChartData>? chartData,
    List<TopProduct>? topProducts,
    List<NotificationModel>? notifications,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      chartData: chartData ?? this.chartData,
      topProducts: topProducts ?? this.topProducts,
      notifications: notifications ?? this.notifications,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        chartData,
        topProducts,
        notifications,
        isRefreshing,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
