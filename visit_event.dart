import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/visit_model.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class LoadVisits extends VisitEvent {
  final DateTime? date;
  final String? status;
  final int page;
  final int limit;

  const LoadVisits({
    this.date,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [date, status, page, limit];
}

class LoadTodayVisits extends VisitEvent {
  const LoadTodayVisits();
}

class LoadVisitDetails extends VisitEvent {
  final String visitId;

  const LoadVisitDetails(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class CreateVisit extends VisitEvent {
  final Visit visit;

  const CreateVisit(this.visit);

  @override
  List<Object?> get props => [visit];
}

class UpdateVisit extends VisitEvent {
  final String visitId;
  final Map<String, dynamic> data;

  const UpdateVisit(this.visitId, this.data);

  @override
  List<Object?> get props => [visitId, data];
}

class CancelVisit extends VisitEvent {
  final String visitId;
  final String reason;

  const CancelVisit(this.visitId, this.reason);

  @override
  List<Object?> get props => [visitId, reason];
}

class StartVisit extends VisitEvent {
  final String visitId;
  final LatLng location;

  const StartVisit(this.visitId, this.location);

  @override
  List<Object?> get props => [visitId, location];
}

class CompleteVisit extends VisitEvent {
  final String visitId;
  final LatLng location;
  final String? notes;
  final String? outcome;

  const CompleteVisit({
    required this.visitId,
    required this.location,
    this.notes,
    this.outcome,
  });

  @override
  List<Object?> get props => [visitId, location, notes, outcome];
}

class CheckInVisit extends VisitEvent {
  final String visitId;
  final LatLng location;

  const CheckInVisit(this.visitId, this.location);

  @override
  List<Object?> get props => [visitId, location];
}

class CheckOutVisit extends VisitEvent {
  final String visitId;
  final LatLng location;

  const CheckOutVisit(this.visitId, this.location);

  @override
  List<Object?> get props => [visitId, location];
}

class AddVisitPhoto extends VisitEvent {
  final String visitId;
  final String photoPath;
  final String? caption;

  const AddVisitPhoto({
    required this.visitId,
    required this.photoPath,
    this.caption,
  });

  @override
  List<Object?> get props => [visitId, photoPath, caption];
}

class AddVisitNote extends VisitEvent {
  final String visitId;
  final String note;

  const AddVisitNote(this.visitId, this.note);

  @override
  List<Object?> get props => [visitId, note];
}

class RecordVisitOrder extends VisitEvent {
  final String visitId;
  final String orderId;
  final double orderValue;

  const RecordVisitOrder({
    required this.visitId,
    required this.orderId,
    required this.orderValue,
  });

  @override
  List<Object?> get props => [visitId, orderId, orderValue];
}

class ScheduleVisit extends VisitEvent {
  final String customerId;
  final String customerName;
  final DateTime scheduledAt;
  final String? purpose;
  final String? notes;
  final LatLng? location;

  const ScheduleVisit({
    required this.customerId,
    required this.customerName,
    required this.scheduledAt,
    this.purpose,
    this.notes,
    this.location,
  });

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        scheduledAt,
        purpose,
        notes,
        location,
      ];
}

class RescheduleVisit extends VisitEvent {
  final String visitId;
  final DateTime newScheduledAt;
  final String? reason;

  const RescheduleVisit({
    required this.visitId,
    required this.newScheduledAt,
    this.reason,
  });

  @override
  List<Object?> get props => [visitId, newScheduledAt, reason];
}

class LoadVisitsByCustomer extends VisitEvent {
  final String customerId;

  const LoadVisitsByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadVisitsByDateRange extends VisitEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadVisitsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshVisits extends VisitEvent {
  const RefreshVisits();
}

class UpdateVisitLocation extends VisitEvent {
  final LatLng location;

  const UpdateVisitLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class GetOptimizedRoute extends VisitEvent {
  final List<String> visitIds;

  const GetOptimizedRoute(this.visitIds);

  @override
  List<Object?> get props => [visitIds];
}

class SyncOfflineVisits extends VisitEvent {
  const SyncOfflineVisits();
}
