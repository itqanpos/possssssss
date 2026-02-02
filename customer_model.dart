import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class Customer extends Equatable {
  final String id;
  final String? code;
  final String companyId;
  final String? branchId;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? email;
  final String phone;
  final String? phone2;
  final String type;
  final String? companyName;
  final String? taxNumber;
  final String? commercialRegistration;
  final Address? address;
  final List<Address>? shippingAddresses;
  final Location? location;
  final String? category;
  final List<String>? tags;
  final double creditLimit;
  final double currentBalance;
  final int? paymentTerms;
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final DateTime? lastOrderDate;
  final String status;
  final bool isActive;
  final bool isVip;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    this.code,
    required this.companyId,
    this.branchId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.email,
    required this.phone,
    this.phone2,
    this.type = 'individual',
    this.companyName,
    this.taxNumber,
    this.commercialRegistration,
    this.address,
    this.shippingAddresses,
    this.location,
    this.category,
    this.tags,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.paymentTerms,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.averageOrderValue = 0,
    this.lastOrderDate,
    this.status = 'active',
    this.isActive = true,
    this.isVip = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    String? id,
    String? code,
    String? companyId,
    String? branchId,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? phone,
    String? phone2,
    String? type,
    String? companyName,
    String? taxNumber,
    String? commercialRegistration,
    Address? address,
    List<Address>? shippingAddresses,
    Location? location,
    String? category,
    List<String>? tags,
    double? creditLimit,
    double? currentBalance,
    int? paymentTerms,
    int? totalOrders,
    double? totalSpent,
    double? averageOrderValue,
    DateTime? lastOrderDate,
    String? status,
    bool? isActive,
    bool? isVip,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      type: type ?? this.type,
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      commercialRegistration:
          commercialRegistration ?? this.commercialRegistration,
      address: address ?? this.address,
      shippingAddresses: shippingAddresses ?? this.shippingAddresses,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVip: isVip ?? this.isVip,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        companyId,
        branchId,
        firstName,
        lastName,
        displayName,
        email,
        phone,
        phone2,
        type,
        companyName,
        taxNumber,
        commercialRegistration,
        address,
        shippingAddresses,
        location,
        category,
        tags,
        creditLimit,
        currentBalance,
        paymentTerms,
        totalOrders,
        totalSpent,
        averageOrderValue,
        lastOrderDate,
        status,
        isActive,
        isVip,
        notes,
        createdAt,
        updatedAt,
      ];

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  bool get hasBalance => currentBalance > 0;
  bool get isCompany => type == 'company';
}

@JsonSerializable()
class Address extends Equatable {
  final String? id;
  final String? name;
  final String street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final bool? isDefault;
  final Location? coordinates;

  const Address({
    this.id,
    this.name,
    required this.street,
    this.building,
    this.floor,
    this.apartment,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'SA',
    this.isDefault,
    this.coordinates,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        street,
        building,
        floor,
        apartment,
        city,
        state,
        postalCode,
        country,
        isDefault,
        coordinates,
      ];

  String get fullAddress {
    final parts = <String>[
      street,
      if (building != null) 'Building $building',
      if (floor != null) 'Floor $floor',
      if (apartment != null) 'Apt $apartment',
      city,
      if (state != null) state!,
      country,
    ];
    return parts.join(', ');
  }
}

@JsonSerializable()
class Location extends Equatable {
  final double lat;
  final double lng;

  const Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [lat, lng];
}
