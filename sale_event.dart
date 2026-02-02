import 'package:equatable/equatable.dart';
import '../../models/sale_model.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSales extends SaleEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final int page;
  final int limit;

  const LoadSales({
    this.startDate,
    this.endDate,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [startDate, endDate, status, page, limit];
}

class LoadSaleDetails extends SaleEvent {
  final String saleId;

  const LoadSaleDetails(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

class CreateSale extends SaleEvent {
  final Sale sale;

  const CreateSale(this.sale);

  @override
  List<Object?> get props => [sale];
}

class UpdateSale extends SaleEvent {
  final String saleId;
  final Map<String, dynamic> data;

  const UpdateSale(this.saleId, this.data);

  @override
  List<Object?> get props => [saleId, data];
}

class CancelSale extends SaleEvent {
  final String saleId;
  final String reason;

  const CancelSale(this.saleId, this.reason);

  @override
  List<Object?> get props => [saleId, reason];
}

class AddSaleItem extends SaleEvent {
  final SaleItem item;

  const AddSaleItem(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveSaleItem extends SaleEvent {
  final String productId;

  const RemoveSaleItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateSaleItemQuantity extends SaleEvent {
  final String productId;
  final int quantity;

  const UpdateSaleItemQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class UpdateSaleItemDiscount extends SaleEvent {
  final String productId;
  final double discount;

  const UpdateSaleItemDiscount(this.productId, this.discount);

  @override
  List<Object?> get props => [productId, discount];
}

class ApplyDiscount extends SaleEvent {
  final double discount;
  final String discountType;

  const ApplyDiscount({
    required this.discount,
    required this.discountType,
  });

  @override
  List<Object?> get props => [discount, discountType];
}

class ApplyTax extends SaleEvent {
  final double taxRate;

  const ApplyTax(this.taxRate);

  @override
  List<Object?> get props => [taxRate];
}

class SetCustomer extends SaleEvent {
  final String? customerId;
  final String? customerName;

  const SetCustomer({this.customerId, this.customerName});

  @override
  List<Object?> get props => [customerId, customerName];
}

class SetPaymentMethod extends SaleEvent {
  final String paymentMethod;

  const SetPaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class ProcessPayment extends SaleEvent {
  final double amount;
  final String paymentMethod;
  final String? reference;

  const ProcessPayment({
    required this.amount,
    required this.paymentMethod,
    this.reference,
  });

  @override
  List<Object?> get props => [amount, paymentMethod, reference];
}

class ClearCurrentSale extends SaleEvent {
  const ClearCurrentSale();
}

class RefreshSales extends SaleEvent {
  const RefreshSales();
}

class SearchSales extends SaleEvent {
  final String query;

  const SearchSales(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadSalesByCustomer extends SaleEvent {
  final String customerId;

  const LoadSalesByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadSalesByDateRange extends SaleEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSalesByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class SyncOfflineSales extends SaleEvent {
  const SyncOfflineSales();
}
