import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'customer_model.dart';

part 'sale_model.g.dart';

@JsonSerializable()
class Sale extends Equatable {
  final String id;
  final String invoiceNumber;
  final String companyId;
  final String branchId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String salesRepId;
  final String salesRepName;
  final List<SaleItem> items;
  final double subtotal;
  final double discountAmount;
  final double discountPercentage;
  final double taxAmount;
  final double taxRate;
  final double shippingCost;
  final double total;
  final String currency;
  final String paymentStatus;
  final String paymentMethod;
  final double paidAmount;
  final double remainingAmount;
  final List<Payment> payments;
  final String status;
  final String? deliveryStatus;
  final DateTime? deliveryDate;
  final Address? deliveryAddress;
  final String? notes;
  final String? internalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool isPosSale;
  final String? posSessionId;
  final String? receiptNumber;
  final String source;
  final bool isRefunded;
  final double? refundAmount;
  final String? refundReason;
  final DateTime? refundedAt;
  final int totalItems;

  const Sale({
    required this.id,
    required this.invoiceNumber,
    required this.companyId,
    required this.branchId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.salesRepId,
    required this.salesRepName,
    required this.items,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.discountPercentage = 0,
    this.taxAmount = 0,
    this.taxRate = 0,
    this.shippingCost = 0,
    this.total = 0,
    this.currency = 'SAR',
    this.paymentStatus = 'pending',
    required this.paymentMethod,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.payments = const [],
    this.status = 'pending',
    this.deliveryStatus,
    this.deliveryDate,
    this.deliveryAddress,
    this.notes,
    this.internalNotes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.isPosSale = false,
    this.posSessionId,
    this.receiptNumber,
    this.source = 'mobile',
    this.isRefunded = false,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
    this.totalItems = 0,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    String? companyId,
    String? branchId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? salesRepId,
    String? salesRepName,
    List<SaleItem>? items,
    double? subtotal,
    double? discountAmount,
    double? discountPercentage,
    double? taxAmount,
    double? taxRate,
    double? shippingCost,
    double? total,
    String? currency,
    String? paymentStatus,
    String? paymentMethod,
    double? paidAmount,
    double? remainingAmount,
    List<Payment>? payments,
    String? status,
    String? deliveryStatus,
    DateTime? deliveryDate,
    Address? deliveryAddress,
    String? notes,
    String? internalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isPosSale,
    String? posSessionId,
    String? receiptNumber,
    String? source,
    bool? isRefunded,
    double? refundAmount,
    String? refundReason,
    DateTime? refundedAt,
    int? totalItems,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      salesRepId: salesRepId ?? this.salesRepId,
      salesRepName: salesRepName ?? this.salesRepName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      payments: payments ?? this.payments,
      status: status ?? this.status,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      internalNotes: internalNotes ?? this.internalNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isPosSale: isPosSale ?? this.isPosSale,
      posSessionId: posSessionId ?? this.posSessionId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      source: source ?? this.source,
      isRefunded: isRefunded ?? this.isRefunded,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        companyId,
        branchId,
        customerId,
        customerName,
        customerPhone,
        customerEmail,
        salesRepId,
        salesRepName,
        items,
        subtotal,
        discountAmount,
        discountPercentage,
        taxAmount,
        taxRate,
        shippingCost,
        total,
        currency,
        paymentStatus,
        paymentMethod,
        paidAmount,
        remainingAmount,
        payments,
        status,
        deliveryStatus,
        deliveryDate,
        deliveryAddress,
        notes,
        internalNotes,
        createdAt,
        updatedAt,
        completedAt,
        isPosSale,
        posSessionId,
        receiptNumber,
        source,
        isRefunded,
        refundAmount,
        refundReason,
        refundedAt,
        totalItems,
      ];

  bool get isPaid => paymentStatus == 'paid';
  bool get hasRemaining => remainingAmount > 0;
  bool get isCompleted => status == 'completed';
}

@JsonSerializable()
class SaleItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final double discountAmount;
  final double discountPercentage;
  final double taxRate;
  final double taxAmount;
  final double total;
  final int? returnedQuantity;
  final bool isReturned;

  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.variantId,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    this.costPrice = 0,
    this.discountAmount = 0,
    this.discountPercentage = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.total = 0,
    this.returnedQuantity,
    this.isReturned = false,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);

  SaleItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? variantId,
    String? variantName,
    int? quantity,
    double? unitPrice,
    double? costPrice,
    double? discountAmount,
    double? discountPercentage,
    double? taxRate,
    double? taxAmount,
    double? total,
    int? returnedQuantity,
    bool? isReturned,
  }) {
    return SaleItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      isReturned: isReturned ?? this.isReturned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productSku,
        variantId,
        variantName,
        quantity,
        unitPrice,
        costPrice,
        discountAmount,
        discountPercentage,
        taxRate,
        taxAmount,
        total,
        returnedQuantity,
        isReturned,
      ];

  double get subtotal => quantity * unitPrice;
  double get discount => discountAmount + (subtotal * discountPercentage / 100);
  double get priceAfterDiscount => subtotal - discount;
}

@JsonSerializable()
class Payment extends Equatable {
  final String id;
  final double amount;
  final String method;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  const Payment({
    required this.id,
    required this.amount,
    required this.method,
    this.reference,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  @override
  List<Object?> get props => [
        id,
        amount,
        method,
        reference,
        notes,
        createdAt,
        createdBy,
      ];
}

@JsonSerializable()
class CreateSaleRequest extends Equatable {
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final List<CreateSaleItemRequest> items;
  final double? discountAmount;
  final double? discountPercentage;
  final double? taxRate;
  final double? shippingCost;
  final String paymentMethod;
  final double? paidAmount;
  final String? notes;
  final String? internalNotes;
  final Address? deliveryAddress;
  final bool? isPosSale;
  final String? posSessionId;

  const CreateSaleRequest({
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.items,
    this.discountAmount,
    this.discountPercentage,
    this.taxRate,
    this.shippingCost,
    required this.paymentMethod,
    this.paidAmount,
    this.notes,
    this.internalNotes,
    this.deliveryAddress,
    this.isPosSale,
    this.posSessionId,
  });

  factory CreateSaleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleRequestToJson(this);

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        customerPhone,
        items,
        discountAmount,
        discountPercentage,
        taxRate,
        shippingCost,
        paymentMethod,
        paidAmount,
        notes,
        internalNotes,
        deliveryAddress,
        isPosSale,
        posSessionId,
      ];
}

@JsonSerializable()
class CreateSaleItemRequest extends Equatable {
  final String productId;
  final String? variantId;
  final int quantity;
  final double? unitPrice;
  final double? discountAmount;
  final double? discountPercentage;

  const CreateSaleItemRequest({
    required this.productId,
    this.variantId,
    required this.quantity,
    this.unitPrice,
    this.discountAmount,
    this.discountPercentage,
  });

  factory CreateSaleItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSaleItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSaleItemRequestToJson(this);

  @override
  List<Object?> get props => [
        productId,
        variantId,
        quantity,
        unitPrice,
        discountAmount,
        discountPercentage,
      ];
}
