import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../repositories/visit_repository.dart';
import '../../services/local_storage_service.dart';
import '../../services/location_service.dart';
import '../../models/visit_model.dart';
import 'visit_event.dart';
import 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final VisitRepository _visitRepository;
  final LocalStorageService _localStorage;
  final LocationService _locationService;

  VisitBloc({
    required VisitRepository visitRepository,
    required LocalStorageService localStorage,
    required LocationService locationService,
  })  : _visitRepository = visitRepository,
        _localStorage = localStorage,
        _locationService = locationService,
        super(const VisitState()) {
    on<LoadVisits>(_onLoadVisits);
    on<LoadTodayVisits>(_onLoadTodayVisits);
    on<LoadVisitDetails>(_onLoadVisitDetails);
    on<CreateVisit>(_onCreateVisit);
    on<UpdateVisit>(_onUpdateVisit);
    on<CancelVisit>(_onCancelVisit);
    on<StartVisit>(_onStartVisit);
    on<CompleteVisit>(_onCompleteVisit);
    on<CheckInVisit>(_onCheckInVisit);
    on<CheckOutVisit>(_onCheckOutVisit);
    on<AddVisitPhoto>(_onAddVisitPhoto);
    on<AddVisitNote>(_onAddVisitNote);
    on<RecordVisitOrder>(_onRecordVisitOrder);
    on<ScheduleVisit>(_onScheduleVisit);
    on<RescheduleVisit>(_onRescheduleVisit);
    on<LoadVisitsByCustomer>(_onLoadVisitsByCustomer);
    on<LoadVisitsByDateRange>(_onLoadVisitsByDateRange);
    on<RefreshVisits>(_onRefreshVisits);
    on<UpdateVisitLocation>(_onUpdateVisitLocation);
    on<GetOptimizedRoute>(_onGetOptimizedRoute);
    on<SyncOfflineVisits>(_onSyncOfflineVisits);

    _initLocationTracking();
  }

  void _initLocationTracking() {
    _locationService.getPositionStream().listen((position) {
      add(UpdateVisitLocation(
        LatLng(position.latitude, position.longitude),
      ));
    });
  }

  Future<void> _onLoadVisits(LoadVisits event, Emitter<VisitState> emit) async {
    if (event.page == 1) {
      emit(state.copyWith(isLoading: true, clearError: true));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final isOnline = await _localStorage.isOnline();

      if (!isOnline) {
        final offlineVisits = await _localStorage.getPendingVisits();
        emit(state.copyWith(
          visits: offlineVisits,
          isLoading: false,
          isOffline: true,
          pendingSyncVisits: offlineVisits,
        ));
        return;
      }

      final result = await _visitRepository.getVisits(
        page: event.page,
        limit: event.limit,
        date: event.date,
        status: event.status,
      );

      final visits = result['visits'] as List<Visit>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final totalPages = pagination['totalPages'] as int;

      final allVisits = event.page == 1 ? visits : [...state.visits, ...visits];

      emit(state.copyWith(
        visits: allVisits,
        isLoading: false,
        hasReachedMax: event.page >= totalPages,
        currentPage: event.page,
        isOffline: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل الزيارات: $e',
      ));
    }
  }

  Future<void> _onLoadTodayVisits(
    LoadTodayVisits event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final visits = await _visitRepository.getTodayVisits();

      emit(state.copyWith(
        todayVisits: visits,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل زيارات اليوم: $e',
      ));
    }
  }

  Future<void> _onLoadVisitDetails(
    LoadVisitDetails event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final visit = await _visitRepository.getVisitById(event.visitId);
      emit(state.copyWith(
        currentVisit: visit,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل تفاصيل الزيارة: $e',
      ));
    }
  }

  Future<void> _onCreateVisit(
    CreateVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearError: true));

    try {
      final isOnline = await _localStorage.isOnline();

      if (!isOnline) {
        await _localStorage.savePendingVisit(event.visit);
        emit(state.copyWith(
          isCreating: false,
          isOffline: true,
        ));
        return;
      }

      final visit = await _visitRepository.createVisit(event.visit);

      emit(state.copyWith(
        isCreating: false,
        visits: [visit, ...state.visits],
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: 'فشل في إنشاء الزيارة: $e',
      ));
    }
  }

  Future<void> _onUpdateVisit(
    UpdateVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.updateVisit(event.visitId, event.data);

      final updatedVisits = state.visits.map((v) {
        return v.id == visit.id ? visit : v;
      }).toList();

      emit(state.copyWith(
        isUpdating: false,
        visits: updatedVisits,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في تحديث الزيارة: $e',
      ));
    }
  }

  Future<void> _onCancelVisit(
    CancelVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      await _visitRepository.cancelVisit(event.visitId, event.reason);

      final updatedVisits = state.visits.map((v) {
        if (v.id == event.visitId) {
          return v.copyWith(status: 'cancelled');
        }
        return v;
      }).toList();

      emit(state.copyWith(
        isUpdating: false,
        visits: updatedVisits,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في إلغاء الزيارة: $e',
      ));
    }
  }

  Future<void> _onStartVisit(
    StartVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.startVisit(
        event.visitId,
        event.location.latitude,
        event.location.longitude,
      );

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في بدء الزيارة: $e',
      ));
    }
  }

  Future<void> _onCompleteVisit(
    CompleteVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.completeVisit(
        event.visitId,
        event.location.latitude,
        event.location.longitude,
        event.notes,
        event.outcome,
      );

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في إكمال الزيارة: $e',
      ));
    }
  }

  Future<void> _onCheckInVisit(
    CheckInVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isCheckingIn: true, clearError: true));

    try {
      final visit = await _visitRepository.checkIn(
        event.visitId,
        event.location.latitude,
        event.location.longitude,
      );

      emit(state.copyWith(
        isCheckingIn: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCheckingIn: false,
        error: 'فشل في تسجيل الدخول: $e',
      ));
    }
  }

  Future<void> _onCheckOutVisit(
    CheckOutVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isCheckingOut: true, clearError: true));

    try {
      final visit = await _visitRepository.checkOut(
        event.visitId,
        event.location.latitude,
        event.location.longitude,
      );

      emit(state.copyWith(
        isCheckingOut: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCheckingOut: false,
        error: 'فشل في تسجيل الخروج: $e',
      ));
    }
  }

  Future<void> _onAddVisitPhoto(
    AddVisitPhoto event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.addPhoto(
        event.visitId,
        event.photoPath,
        event.caption,
      );

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في إضافة الصورة: $e',
      ));
    }
  }

  Future<void> _onAddVisitNote(
    AddVisitNote event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.addNote(event.visitId, event.note);

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في إضافة الملاحظة: $e',
      ));
    }
  }

  Future<void> _onRecordVisitOrder(
    RecordVisitOrder event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.recordOrder(
        event.visitId,
        event.orderId,
        event.orderValue,
      );

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في تسجيل الطلب: $e',
      ));
    }
  }

  Future<void> _onScheduleVisit(
    ScheduleVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearError: true));

    try {
      final visit = Visit(
        id: '',
        customerId: event.customerId,
        customerName: event.customerName,
        scheduledAt: event.scheduledAt,
        purpose: event.purpose ?? 'زيارة عمل',
        notes: event.notes,
        status: 'scheduled',
        location: event.location != null
            ? VisitLocation(
                latitude: event.location!.latitude,
                longitude: event.location!.longitude,
              )
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdVisit = await _visitRepository.createVisit(visit);

      emit(state.copyWith(
        isCreating: false,
        visits: [createdVisit, ...state.visits],
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: 'فشل في جدولة الزيارة: $e',
      ));
    }
  }

  Future<void> _onRescheduleVisit(
    RescheduleVisit event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final visit = await _visitRepository.rescheduleVisit(
        event.visitId,
        event.newScheduledAt,
        event.reason,
      );

      emit(state.copyWith(
        isUpdating: false,
        currentVisit: visit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في إعادة جدولة الزيارة: $e',
      ));
    }
  }

  Future<void> _onLoadVisitsByCustomer(
    LoadVisitsByCustomer event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final visits = await _visitRepository.getVisitsByCustomer(event.customerId);

      emit(state.copyWith(
        visits: visits,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل زيارات العميل: $e',
      ));
    }
  }

  Future<void> _onLoadVisitsByDateRange(
    LoadVisitsByDateRange event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final visits = await _visitRepository.getVisitsByDateRange(
        event.startDate,
        event.endDate,
      );

      emit(state.copyWith(
        visits: visits,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل الزيارات: $e',
      ));
    }
  }

  Future<void> _onRefreshVisits(
    RefreshVisits event,
    Emitter<VisitState> emit,
  ) async {
    add(const LoadVisits(page: 1));
  }

  void _onUpdateVisitLocation(
    UpdateVisitLocation event,
    Emitter<VisitState> emit,
  ) {
    emit(state.copyWith(currentLocation: event.location));
  }

  Future<void> _onGetOptimizedRoute(
    GetOptimizedRoute event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final visits = state.todayVisits
          .where((v) => event.visitIds.contains(v.id))
          .toList();

      final route = await _visitRepository.getOptimizedRoute(visits);

      emit(state.copyWith(
        optimizedRoute: route,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل المسار الأمثل: $e',
      ));
    }
  }

  Future<void> _onSyncOfflineVisits(
    SyncOfflineVisits event,
    Emitter<VisitState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final pendingVisits = await _localStorage.getPendingVisits();

      for (final visit in pendingVisits) {
        try {
          await _visitRepository.createVisit(visit);
          await _localStorage.removePendingVisit(visit.id);
        } catch (e) {
          print('فشل في مزامنة الزيارة ${visit.id}: $e');
        }
      }

      emit(state.copyWith(
        isLoading: false,
        pendingSyncVisits: const [],
      ));

      add(const RefreshVisits());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في المزامنة: $e',
      ));
    }
  }
}
