import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardStats extends Equatable {
  final SalesStats sales;
  final OrdersStats orders;
  final CustomersStats customers;
  final InventoryStats inventory;
  final ReceivablesStats receivables;

  const DashboardStats({
    required this.sales,
    required this.orders,
    required this.customers,
    required this.inventory,
    required this.receivables,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);

  @override
  List<Object?> get props => [sales, orders, customers, inventory, receivables];
}

@JsonSerializable()
class SalesStats extends Equatable {
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double lastMonth;
  final double growth;

  const SalesStats({
    this.today = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
    this.lastMonth = 0,
    this.growth = 0,
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) =>
      _$SalesStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SalesStatsToJson(this);

  @override
  List<Object?> get props => [today, thisWeek, thisMonth, lastMonth, growth];
}

@JsonSerializable()
class OrdersStats extends Equatable {
  final int today;
  final int thisWeek;
  final int thisMonth;
  final int pending;

  const OrdersStats({
    this.today = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
    this.pending = 0,
  });

  factory OrdersStats.fromJson(Map<String, dynamic> json) =>
      _$OrdersStatsFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersStatsToJson(this);

  @override
  List<Object?> get props => [today, thisWeek, thisMonth, pending];
}

@JsonSerializable()
class CustomersStats extends Equatable {
  final int total;
  final int newThisMonth;
  final int active;

  const CustomersStats({
    this.total = 0,
    this.newThisMonth = 0,
    this.active = 0,
  });

  factory CustomersStats.fromJson(Map<String, dynamic> json) =>
      _$CustomersStatsFromJson(json);
  Map<String, dynamic> toJson() => _$CustomersStatsToJson(this);

  @override
  List<Object?> get props => [total, newThisMonth, active];
}

@JsonSerializable()
class InventoryStats extends Equatable {
  final int totalProducts;
  final int lowStock;
  final int outOfStock;
  final double totalValue;

  const InventoryStats({
    this.totalProducts = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.totalValue = 0,
  });

  factory InventoryStats.fromJson(Map<String, dynamic> json) =>
      _$InventoryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryStatsToJson(this);

  @override
  List<Object?> get props => [totalProducts, lowStock, outOfStock, totalValue];
}

@JsonSerializable()
class ReceivablesStats extends Equatable {
  final double total;
  final double overdue;
  final double thisMonth;

  const ReceivablesStats({
    this.total = 0,
    this.overdue = 0,
    this.thisMonth = 0,
  });

  factory ReceivablesStats.fromJson(Map<String, dynamic> json) =>
      _$ReceivablesStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ReceivablesStatsToJson(this);

  @override
  List<Object?> get props => [total, overdue, thisMonth];
}

@JsonSerializable()
class SalesChartData extends Equatable {
  final String date;
  final double sales;
  final double amount;
  final int count;

  const SalesChartData({
    required this.date,
    this.sales = 0,
    this.amount = 0,
    this.count = 0,
  });

  factory SalesChartData.fromJson(Map<String, dynamic> json) =>
      _$SalesChartDataFromJson(json);
  Map<String, dynamic> toJson() => _$SalesChartDataToJson(this);

  @override
  List<Object?> get props => [date, sales, amount, count];
}

@JsonSerializable()
class TopProduct extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double total;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.total,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      _$TopProductFromJson(json);
  Map<String, dynamic> toJson() => _$TopProductToJson(this);

  @override
  List<Object?> get props => [productId, productName, quantity, total];
}

@JsonSerializable()
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String companyId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        type,
        title,
        message,
        data,
        isRead,
        readAt,
        actionUrl,
        createdAt,
      ];
}

@JsonSerializable()
class ActivityItem extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String action;
  final String resource;
  final String resourceId;
  final DateTime createdAt;

  const ActivityItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.action,
    required this.resource,
    required this.resourceId,
    required this.createdAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userEmail,
        action,
        resource,
        resourceId,
        createdAt,
      ];

  String get actionText {
    switch (action) {
      case 'CREATE':
        return 'created';
      case 'UPDATE':
        return 'updated';
      case 'DELETE':
        return 'deleted';
      default:
        return action.toLowerCase();
    }
  }

  String get resourceText {
    switch (resource) {
      case 'sales':
        return 'a sale';
      case 'products':
        return 'a product';
      case 'customers':
        return 'a customer';
      case 'users':
        return 'a user';
      default:
        return resource;
    }
  }
}
