import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'customer_model.dart';

part 'visit_model.g.dart';

@JsonSerializable()
class SalesVisit extends Equatable {
  final String id;
  final String companyId;
  final String salesRepId;
  final String salesRepName;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final DateTime visitDate;
  final String visitType;
  final Location? location;
  final String status;
  final String? purpose;
  final String? notes;
  final String? outcome;
  final bool orderCreated;
  final String? orderId;
  final double? orderAmount;
  final DateTime? checkInAt;
  final Location? checkInLocation;
  final DateTime? checkOutAt;
  final Location? checkOutLocation;
  final int? duration;
  final List<String>? photos;
  final String? customerSignature;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesVisit({
    required this.id,
    required this.companyId,
    required this.salesRepId,
    required this.salesRepName,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.visitDate,
    required this.visitType,
    this.location,
    this.status = 'scheduled',
    this.purpose,
    this.notes,
    this.outcome,
    this.orderCreated = false,
    this.orderId,
    this.orderAmount,
    this.checkInAt,
    this.checkInLocation,
    this.checkOutAt,
    this.checkOutLocation,
    this.duration,
    this.photos,
    this.customerSignature,
    this.reminderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesVisit.fromJson(Map<String, dynamic> json) =>
      _$SalesVisitFromJson(json);
  Map<String, dynamic> toJson() => _$SalesVisitToJson(this);

  SalesVisit copyWith({
    String? id,
    String? companyId,
    String? salesRepId,
    String? salesRepName,
    String? customerId,
    String? customerName,
    String? customerPhone,
    DateTime? visitDate,
    String? visitType,
    Location? location,
    String? status,
    String? purpose,
    String? notes,
    String? outcome,
    bool? orderCreated,
    String? orderId,
    double? orderAmount,
    DateTime? checkInAt,
    Location? checkInLocation,
    DateTime? checkOutAt,
    Location? checkOutLocation,
    int? duration,
    List<String>? photos,
    String? customerSignature,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesVisit(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      salesRepId: salesRepId ?? this.salesRepId,
      salesRepName: salesRepName ?? this.salesRepName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      visitDate: visitDate ?? this.visitDate,
      visitType: visitType ?? this.visitType,
      location: location ?? this.location,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      outcome: outcome ?? this.outcome,
      orderCreated: orderCreated ?? this.orderCreated,
      orderId: orderId ?? this.orderId,
      orderAmount: orderAmount ?? this.orderAmount,
      checkInAt: checkInAt ?? this.checkInAt,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      duration: duration ?? this.duration,
      photos: photos ?? this.photos,
      customerSignature: customerSignature ?? this.customerSignature,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        salesRepId,
        salesRepName,
        customerId,
        customerName,
        customerPhone,
        visitDate,
        visitType,
        location,
        status,
        purpose,
        notes,
        outcome,
        orderCreated,
        orderId,
        orderAmount,
        checkInAt,
        checkInLocation,
        checkOutAt,
        checkOutLocation,
        duration,
        photos,
        customerSignature,
        reminderDate,
        createdAt,
        updatedAt,
      ];

  bool get isScheduled => status == 'scheduled';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get hasCheckIn => checkInAt != null;
  bool get hasCheckOut => checkOutAt != null;

  String get durationFormatted {
    if (duration == null) return '--';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

@JsonSerializable()
class CreateVisitRequest extends Equatable {
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final DateTime visitDate;
  final String visitType;
  final String? purpose;
  final String? notes;
  final Location? location;
  final DateTime? reminderDate;

  const CreateVisitRequest({
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.visitDate,
    required this.visitType,
    this.purpose,
    this.notes,
    this.location,
    this.reminderDate,
  });

  factory CreateVisitRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVisitRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateVisitRequestToJson(this);

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        customerPhone,
        visitDate,
        visitType,
        purpose,
        notes,
        location,
        reminderDate,
      ];
}

@JsonSerializable()
class CheckInRequest extends Equatable {
  final Location location;
  final String? notes;

  const CheckInRequest({
    required this.location,
    this.notes,
  });

  factory CheckInRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckInRequestToJson(this);

  @override
  List<Object?> get props => [location, notes];
}

@JsonSerializable()
class CheckOutRequest extends Equatable {
  final Location location;
  final String? outcome;
  final String? notes;
  final String? orderId;
  final double? orderAmount;

  const CheckOutRequest({
    required this.location,
    this.outcome,
    this.notes,
    this.orderId,
    this.orderAmount,
  });

  factory CheckOutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckOutRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckOutRequestToJson(this);

  @override
  List<Object?> get props => [location, outcome, notes, orderId, orderAmount];
}

@JsonSerializable()
class SalesRoute extends Equatable {
  final String id;
  final String companyId;
  final String salesRepId;
  final String salesRepName;
  final String name;
  final String? description;
  final int dayOfWeek;
  final String? startTime;
  final String? endTime;
  final List<RouteCustomer> customers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesRoute({
    required this.id,
    required this.companyId,
    required this.salesRepId,
    required this.salesRepName,
    required this.name,
    this.description,
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    required this.customers,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesRoute.fromJson(Map<String, dynamic> json) =>
      _$SalesRouteFromJson(json);
  Map<String, dynamic> toJson() => _$SalesRouteToJson(this);

  @override
  List<Object?> get props => [
        id,
        companyId,
        salesRepId,
        salesRepName,
        name,
        description,
        dayOfWeek,
        startTime,
        endTime,
        customers,
        isActive,
        createdAt,
        updatedAt,
      ];

  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayOfWeek];
  }
}

@JsonSerializable()
class RouteCustomer extends Equatable {
  final String customerId;
  final String customerName;
  final String? address;
  final Location? location;
  final int sortOrder;
  final int? estimatedDuration;

  const RouteCustomer({
    required this.customerId,
    required this.customerName,
    this.address,
    this.location,
    required this.sortOrder,
    this.estimatedDuration,
  });

  factory RouteCustomer.fromJson(Map<String, dynamic> json) =>
      _$RouteCustomerFromJson(json);
  Map<String, dynamic> toJson() => _$RouteCustomerToJson(this);

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        address,
        location,
        sortOrder,
        estimatedDuration,
      ];
}
