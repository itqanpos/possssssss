import 'package:equatable/equatable.dart';
import '../../models/sale_model.dart';

class SaleState extends Equatable {
  final List<Sale> sales;
  final Sale? currentSale;
  final List<SaleItem> currentItems;
  final double subtotal;
  final double discount;
  final String discountType;
  final double tax;
  final double taxRate;
  final double total;
  final String? customerId;
  final String? customerName;
  final String paymentMethod;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isCancelling;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;
  final bool isOffline;
  final List<Sale> pendingSyncSales;

  const SaleState({
    this.sales = const [],
    this.currentSale,
    this.currentItems = const [],
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.discountType = 'fixed',
    this.tax = 0.0,
    this.taxRate = 0.0,
    this.total = 0.0,
    this.customerId,
    this.customerName,
    this.paymentMethod = 'cash',
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isCancelling = false,
    this.error,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isOffline = false,
    this.pendingSyncSales = const [],
  });

  SaleState copyWith({
    List<Sale>? sales,
    Sale? currentSale,
    List<SaleItem>? currentItems,
    double? subtotal,
    double? discount,
    String? discountType,
    double? tax,
    double? taxRate,
    double? total,
    String? customerId,
    String? customerName,
    String? paymentMethod,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isCancelling,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
    bool? isOffline,
    List<Sale>? pendingSyncSales,
    bool clearCurrentSale = false,
    bool clearError = false,
  }) {
    return SaleState(
      sales: sales ?? this.sales,
      currentSale: clearCurrentSale ? null : (currentSale ?? this.currentSale),
      currentItems: currentItems ?? this.currentItems,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      tax: tax ?? this.tax,
      taxRate: taxRate ?? this.taxRate,
      total: total ?? this.total,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isCancelling: isCancelling ?? this.isCancelling,
      error: clearError ? null : (error ?? this.error),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isOffline: isOffline ?? this.isOffline,
      pendingSyncSales: pendingSyncSales ?? this.pendingSyncSales,
    );
  }

  @override
  List<Object?> get props => [
        sales,
        currentSale,
        currentItems,
        subtotal,
        discount,
        discountType,
        tax,
        taxRate,
        total,
        customerId,
        customerName,
        paymentMethod,
        isLoading,
        isCreating,
        isUpdating,
        isCancelling,
        error,
        hasReachedMax,
        currentPage,
        isOffline,
        pendingSyncSales,
      ];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SalesLoaded extends SaleState {
  const SalesLoaded({
    required List<Sale> sales,
    required bool hasReachedMax,
    required int currentPage,
  }) : super(
          sales: sales,
          hasReachedMax: hasReachedMax,
          currentPage: currentPage,
        );
}

class SaleDetailsLoaded extends SaleState {
  const SaleDetailsLoaded({
    required Sale sale,
  }) : super(currentSale: sale);
}

class SaleCreating extends SaleState {
  const SaleCreating();
}

class SaleCreated extends SaleState {
  final Sale sale;

  const SaleCreated(this.sale);

  @override
  List<Object?> get props => [sale];
}

class SaleUpdating extends SaleState {
  const SaleUpdating();
}

class SaleUpdated extends SaleState {
  final Sale sale;

  const SaleUpdated(this.sale);

  @override
  List<Object?> get props => [sale];
}

class SaleCancelling extends SaleState {
  const SaleCancelling();
}

class SaleCancelled extends SaleState {
  final String saleId;

  const SaleCancelled(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message) : super(error: message);

  @override
  List<Object?> get props => [message];
}

class CurrentSaleUpdated extends SaleState {
  const CurrentSaleUpdated({
    required List<SaleItem> currentItems,
    required double subtotal,
    required double discount,
    required String discountType,
    required double tax,
    required double taxRate,
    required double total,
    String? customerId,
    String? customerName,
    required String paymentMethod,
  }) : super(
          currentItems: currentItems,
          subtotal: subtotal,
          discount: discount,
          discountType: discountType,
          tax: tax,
          taxRate: taxRate,
          total: total,
          customerId: customerId,
          customerName: customerName,
          paymentMethod: paymentMethod,
        );
}

class SaleSyncing extends SaleState {
  const SaleSyncing();
}

class SaleSynced extends SaleState {
  const SaleSynced();
}

class OfflineSalesPending extends SaleState {
  const OfflineSalesPending({
    required List<Sale> pendingSales,
  }) : super(pendingSyncSales: pendingSales, isOffline: true);
}
