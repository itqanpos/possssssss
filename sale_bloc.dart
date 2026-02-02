import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/sale_repository.dart';
import '../../services/local_storage_service.dart';
import '../../models/sale_model.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRepository _saleRepository;
  final LocalStorageService _localStorage;

  SaleBloc({
    required SaleRepository saleRepository,
    required LocalStorageService localStorage,
  })  : _saleRepository = saleRepository,
        _localStorage = localStorage,
        super(const SaleState()) {
    on<LoadSales>(_onLoadSales);
    on<LoadSaleDetails>(_onLoadSaleDetails);
    on<CreateSale>(_onCreateSale);
    on<UpdateSale>(_onUpdateSale);
    on<CancelSale>(_onCancelSale);
    on<AddSaleItem>(_onAddSaleItem);
    on<RemoveSaleItem>(_onRemoveSaleItem);
    on<UpdateSaleItemQuantity>(_onUpdateSaleItemQuantity);
    on<UpdateSaleItemDiscount>(_onUpdateSaleItemDiscount);
    on<ApplyDiscount>(_onApplyDiscount);
    on<ApplyTax>(_onApplyTax);
    on<SetCustomer>(_onSetCustomer);
    on<SetPaymentMethod>(_onSetPaymentMethod);
    on<ProcessPayment>(_onProcessPayment);
    on<ClearCurrentSale>(_onClearCurrentSale);
    on<RefreshSales>(_onRefreshSales);
    on<SearchSales>(_onSearchSales);
    on<LoadSalesByCustomer>(_onLoadSalesByCustomer);
    on<LoadSalesByDateRange>(_onLoadSalesByDateRange);
    on<SyncOfflineSales>(_onSyncOfflineSales);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    if (event.page == 1) {
      emit(state.copyWith(isLoading: true, clearError: true));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final isOnline = await _localStorage.isOnline();
      
      if (!isOnline) {
        final offlineSales = await _localStorage.getPendingSales();
        emit(state.copyWith(
          sales: offlineSales,
          isLoading: false,
          isOffline: true,
          pendingSyncSales: offlineSales,
        ));
        return;
      }

      final result = await _saleRepository.getSales(
        page: event.page,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );

      final sales = result['sales'] as List<Sale>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final totalPages = pagination['totalPages'] as int;

      final allSales = event.page == 1 ? sales : [...state.sales, ...sales];

      emit(state.copyWith(
        sales: allSales,
        isLoading: false,
        hasReachedMax: event.page >= totalPages,
        currentPage: event.page,
        isOffline: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل المبيعات: $e',
      ));
    }
  }

  Future<void> _onLoadSaleDetails(
    LoadSaleDetails event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final sale = await _saleRepository.getSaleById(event.saleId);
      emit(state.copyWith(
        currentSale: sale,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل تفاصيل البيع: $e',
      ));
    }
  }

  Future<void> _onCreateSale(CreateSale event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isCreating: true, clearError: true));

    try {
      final isOnline = await _localStorage.isOnline();
      
      if (!isOnline) {
        await _localStorage.savePendingSale(event.sale);
        emit(state.copyWith(
          isCreating: false,
          isOffline: true,
        ));
        return;
      }

      final sale = await _saleRepository.createSale(event.sale);
      
      emit(state.copyWith(
        isCreating: false,
        sales: [sale, ...state.sales],
        clearCurrentSale: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: 'فشل في إنشاء البيع: $e',
      ));
    }
  }

  Future<void> _onUpdateSale(UpdateSale event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final sale = await _saleRepository.updateSale(event.saleId, event.data);
      
      final updatedSales = state.sales.map((s) {
        return s.id == sale.id ? sale : s;
      }).toList();

      emit(state.copyWith(
        isUpdating: false,
        sales: updatedSales,
        currentSale: sale,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'فشل في تحديث البيع: $e',
      ));
    }
  }

  Future<void> _onCancelSale(CancelSale event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isCancelling: true, clearError: true));

    try {
      await _saleRepository.cancelSale(event.saleId, event.reason);
      
      final updatedSales = state.sales.map((s) {
        if (s.id == event.saleId) {
          return s.copyWith(status: 'cancelled');
        }
        return s;
      }).toList();

      emit(state.copyWith(
        isCancelling: false,
        sales: updatedSales,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCancelling: false,
        error: 'فشل في إلغاء البيع: $e',
      ));
    }
  }

  void _onAddSaleItem(AddSaleItem event, Emitter<SaleState> emit) {
    final existingIndex = state.currentItems.indexWhere(
      (item) => item.productId == event.item.productId,
    );

    List<SaleItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = List.from(state.currentItems);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + event.item.quantity,
      );
    } else {
      updatedItems = [...state.currentItems, event.item];
    }

    _recalculateAndEmit(updatedItems, emit);
  }

  void _onRemoveSaleItem(RemoveSaleItem event, Emitter<SaleState> emit) {
    final updatedItems = state.currentItems
        .where((item) => item.productId != event.productId)
        .toList();

    _recalculateAndEmit(updatedItems, emit);
  }

  void _onUpdateSaleItemQuantity(
    UpdateSaleItemQuantity event,
    Emitter<SaleState> emit,
  ) {
    if (event.quantity <= 0) {
      add(RemoveSaleItem(event.productId));
      return;
    }

    final updatedItems = state.currentItems.map((item) {
      if (item.productId == event.productId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    _recalculateAndEmit(updatedItems, emit);
  }

  void _onUpdateSaleItemDiscount(
    UpdateSaleItemDiscount event,
    Emitter<SaleState> emit,
  ) {
    final updatedItems = state.currentItems.map((item) {
      if (item.productId == event.productId) {
        return item.copyWith(discount: event.discount);
      }
      return item;
    }).toList();

    _recalculateAndEmit(updatedItems, emit);
  }

  void _onApplyDiscount(ApplyDiscount event, Emitter<SaleState> emit) {
    emit(state.copyWith(
      discount: event.discount,
      discountType: event.discountType,
    ));
    _recalculateAndEmit(state.currentItems, emit);
  }

  void _onApplyTax(ApplyTax event, Emitter<SaleState> emit) {
    emit(state.copyWith(taxRate: event.taxRate));
    _recalculateAndEmit(state.currentItems, emit);
  }

  void _onSetCustomer(SetCustomer event, Emitter<SaleState> emit) {
    emit(state.copyWith(
      customerId: event.customerId,
      customerName: event.customerName,
    ));
  }

  void _onSetPaymentMethod(SetPaymentMethod event, Emitter<SaleState> emit) {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearError: true));

    try {
      final payment = Payment(
        method: event.paymentMethod,
        amount: event.amount,
        reference: event.reference,
        paidAt: DateTime.now(),
      );

      emit(state.copyWith(isCreating: false));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: 'فشل في معالجة الدفع: $e',
      ));
    }
  }

  void _onClearCurrentSale(ClearCurrentSale event, Emitter<SaleState> emit) {
    emit(const SaleState());
  }

  Future<void> _onRefreshSales(
    RefreshSales event,
    Emitter<SaleState> emit,
  ) async {
    add(const LoadSales(page: 1));
  }

  Future<void> _onSearchSales(SearchSales event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final sales = await _saleRepository.searchSales(event.query);

      emit(state.copyWith(
        sales: sales,
        isLoading: false,
        hasReachedMax: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في البحث: $e',
      ));
    }
  }

  Future<void> _onLoadSalesByCustomer(
    LoadSalesByCustomer event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final sales = await _saleRepository.getSalesByCustomer(event.customerId);

      emit(state.copyWith(
        sales: sales,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل مبيعات العميل: $e',
      ));
    }
  }

  Future<void> _onLoadSalesByDateRange(
    LoadSalesByDateRange event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final sales = await _saleRepository.getSalesByDateRange(
        event.startDate,
        event.endDate,
      );

      emit(state.copyWith(
        sales: sales,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل المبيعات: $e',
      ));
    }
  }

  Future<void> _onSyncOfflineSales(
    SyncOfflineSales event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final pendingSales = await _localStorage.getPendingSales();
      
      for (final sale in pendingSales) {
        try {
          await _saleRepository.createSale(sale);
          await _localStorage.removePendingSale(sale.id);
        } catch (e) {
          print('فشل في مزامنة البيع ${sale.id}: $e');
        }
      }

      emit(state.copyWith(
        isLoading: false,
        pendingSyncSales: const [],
      ));

      add(const RefreshSales());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل في المزامنة: $e',
      ));
    }
  }

  void _recalculateAndEmit(List<SaleItem> items, Emitter<SaleState> emit) {
    double subtotal = 0;
    for (final item in items) {
      subtotal += item.total;
    }

    double discount = state.discount;
    if (state.discountType == 'percentage') {
      discount = subtotal * (state.discount / 100);
    }

    final taxableAmount = subtotal - discount;
    final tax = taxableAmount * (state.taxRate / 100);
    final total = taxableAmount + tax;

    emit(state.copyWith(
      currentItems: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
    ));
  }
}
