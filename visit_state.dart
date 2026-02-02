import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/visit_model.dart';

class VisitState extends Equatable {
  final List<Visit> visits;
  final List<Visit> todayVisits;
  final Visit? currentVisit;
  final LatLng? currentLocation;
  final List<LatLng>? optimizedRoute;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;
  final bool isOffline;
  final List<Visit> pendingSyncVisits;

  const VisitState({
    this.visits = const [],
    this.todayVisits = const [],
    this.currentVisit,
    this.currentLocation,
    this.optimizedRoute,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isCheckingIn = false,
    this.isCheckingOut = false,
    this.error,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isOffline = false,
    this.pendingSyncVisits = const [],
  });

  VisitState copyWith({
    List<Visit>? visits,
    List<Visit>? todayVisits,
    Visit? currentVisit,
    LatLng? currentLocation,
    List<LatLng>? optimizedRoute,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isCheckingIn,
    bool? isCheckingOut,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
    bool? isOffline,
    List<Visit>? pendingSyncVisits,
    bool clearCurrentVisit = false,
    bool clearError = false,
    bool clearOptimizedRoute = false,
  }) {
    return VisitState(
      visits: visits ?? this.visits,
      todayVisits: todayVisits ?? this.todayVisits,
      currentVisit: clearCurrentVisit
          ? null
          : (currentVisit ?? this.currentVisit),
      currentLocation: currentLocation ?? this.currentLocation,
      optimizedRoute: clearOptimizedRoute
          ? null
          : (optimizedRoute ?? this.optimizedRoute),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isCheckingIn: isCheckingIn ?? this.isCheckingIn,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      error: clearError ? null : (error ?? this.error),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isOffline: isOffline ?? this.isOffline,
      pendingSyncVisits: pendingSyncVisits ?? this.pendingSyncVisits,
    );
  }

  @override
  List<Object?> get props => [
        visits,
        todayVisits,
        currentVisit,
        currentLocation,
        optimizedRoute,
        isLoading,
        isCreating,
        isUpdating,
        isCheckingIn,
        isCheckingOut,
        error,
        hasReachedMax,
        currentPage,
        isOffline,
        pendingSyncVisits,
      ];
}

class VisitInitial extends VisitState {
  const VisitInitial();
}

class VisitLoading extends VisitState {
  const VisitLoading();
}

class VisitsLoaded extends VisitState {
  const VisitsLoaded({
    required List<Visit> visits,
    required bool hasReachedMax,
    required int currentPage,
  }) : super(
          visits: visits,
          hasReachedMax: hasReachedMax,
          currentPage: currentPage,
        );
}

class TodayVisitsLoaded extends VisitState {
  const TodayVisitsLoaded({
    required List<Visit> todayVisits,
  }) : super(todayVisits: todayVisits);
}

class VisitDetailsLoaded extends VisitState {
  const VisitDetailsLoaded({
    required Visit visit,
  }) : super(currentVisit: visit);
}

class VisitCreating extends VisitState {
  const VisitCreating();
}

class VisitCreated extends VisitState {
  final Visit visit;

  const VisitCreated(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitUpdating extends VisitState {
  const VisitUpdating();
}

class VisitUpdated extends VisitState {
  final Visit visit;

  const VisitUpdated(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitCancelling extends VisitState {
  const VisitCancelling();
}

class VisitCancelled extends VisitState {
  final String visitId;

  const VisitCancelled(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class VisitCheckingIn extends VisitState {
  const VisitCheckingIn();
}

class VisitCheckedIn extends VisitState {
  final Visit visit;

  const VisitCheckedIn(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitCheckingOut extends VisitState {
  const VisitCheckingOut();
}

class VisitCheckedOut extends VisitState {
  final Visit visit;

  const VisitCheckedOut(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitStarting extends VisitState {
  const VisitStarting();
}

class VisitStarted extends VisitState {
  final Visit visit;

  const VisitStarted(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitCompleting extends VisitState {
  const VisitCompleting();
}

class VisitCompleted extends VisitState {
  final Visit visit;

  const VisitCompleted(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitPhotoAdding extends VisitState {
  const VisitPhotoAdding();
}

class VisitPhotoAdded extends VisitState {
  final Visit visit;

  const VisitPhotoAdded(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitNoteAdding extends VisitState {
  const VisitNoteAdding();
}

class VisitNoteAdded extends VisitState {
  final Visit visit;

  const VisitNoteAdded(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitOrderRecording extends VisitState {
  const VisitOrderRecording();
}

class VisitOrderRecorded extends VisitState {
  final Visit visit;

  const VisitOrderRecorded(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitRescheduling extends VisitState {
  const VisitRescheduling();
}

class VisitRescheduled extends VisitState {
  final Visit visit;

  const VisitRescheduled(this.visit);

  @override
  List<Object?> get props => [visit];
}

class OptimizedRouteLoaded extends VisitState {
  const OptimizedRouteLoaded({
    required List<LatLng> route,
  }) : super(optimizedRoute: route);
}

class VisitError extends VisitState {
  final String message;

  const VisitError(this.message) : super(error: message);

  @override
  List<Object?> get props => [message];
}

class VisitLocationUpdated extends VisitState {
  const VisitLocationUpdated({
    required LatLng location,
  }) : super(currentLocation: location);
}

class VisitSyncing extends VisitState {
  const VisitSyncing();
}

class VisitSynced extends VisitState {
  const VisitSynced();
}

class OfflineVisitsPending extends VisitState {
  const OfflineVisitsPending({
    required List<Visit> pendingVisits,
  }) : super(pendingSyncVisits: pendingVisits, isOffline: true);
}
