import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String? description;
  final String categoryId;
  final String? subcategoryId;
  final String companyId;
  final String? branchId;
  final double costPrice;
  final double sellingPrice;
  final double? wholesalePrice;
  final double? specialPrice;
  final String currency;
  final int quantity;
  final int minQuantity;
  final int? maxQuantity;
  final int? reorderPoint;
  final String unit;
  final double? weight;
  final Dimensions? dimensions;
  final List<String> images;
  final String? thumbnail;
  final double taxRate;
  final bool isTaxable;
  final String status;
  final bool isActive;
  final bool isFeatured;
  final String? brand;
  final String? manufacturer;
  final String? origin;
  final bool hasVariants;
  final List<ProductVariant>? variants;
  final List<ProductAttribute>? attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.sku,
    this.barcode,
    required this.name,
    this.description,
    required this.categoryId,
    this.subcategoryId,
    required this.companyId,
    this.branchId,
    required this.costPrice,
    required this.sellingPrice,
    this.wholesalePrice,
    this.specialPrice,
    this.currency = 'SAR',
    this.quantity = 0,
    this.minQuantity = 0,
    this.maxQuantity,
    this.reorderPoint,
    this.unit = 'piece',
    this.weight,
    this.dimensions,
    this.images = const [],
    this.thumbnail,
    this.taxRate = 0,
    this.isTaxable = true,
    this.status = 'active',
    this.isActive = true,
    this.isFeatured = false,
    this.brand,
    this.manufacturer,
    this.origin,
    this.hasVariants = false,
    this.variants,
    this.attributes,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? sku,
    String? barcode,
    String? name,
    String? description,
    String? categoryId,
    String? subcategoryId,
    String? companyId,
    String? branchId,
    double? costPrice,
    double? sellingPrice,
    double? wholesalePrice,
    double? specialPrice,
    String? currency,
    int? quantity,
    int? minQuantity,
    int? maxQuantity,
    int? reorderPoint,
    String? unit,
    double? weight,
    Dimensions? dimensions,
    List<String>? images,
    String? thumbnail,
    double? taxRate,
    bool? isTaxable,
    String? status,
    bool? isActive,
    bool? isFeatured,
    String? brand,
    String? manufacturer,
    String? origin,
    bool? hasVariants,
    List<ProductVariant>? variants,
    List<ProductAttribute>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      specialPrice: specialPrice ?? this.specialPrice,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      taxRate: taxRate ?? this.taxRate,
      isTaxable: isTaxable ?? this.isTaxable,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      origin: origin ?? this.origin,
      hasVariants: hasVariants ?? this.hasVariants,
      variants: variants ?? this.variants,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        barcode,
        name,
        description,
        categoryId,
        subcategoryId,
        companyId,
        branchId,
        costPrice,
        sellingPrice,
        wholesalePrice,
        specialPrice,
        currency,
        quantity,
        minQuantity,
        maxQuantity,
        reorderPoint,
        unit,
        weight,
        dimensions,
        images,
        thumbnail,
        taxRate,
        isTaxable,
        status,
        isActive,
        isFeatured,
        brand,
        manufacturer,
        origin,
        hasVariants,
        variants,
        attributes,
        createdAt,
        updatedAt,
      ];

  bool get isLowStock => quantity <= minQuantity;
  bool get isOutOfStock => quantity == 0;
  double get priceWithTax => sellingPrice * (1 + taxRate / 100);
}

@JsonSerializable()
class ProductVariant extends Equatable {
  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final Map<String, String> options;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final List<String>? images;
  final bool isActive;

  const ProductVariant({
    required this.id,
    required this.sku,
    this.barcode,
    required this.name,
    required this.options,
    required this.costPrice,
    required this.sellingPrice,
    this.quantity = 0,
    this.images,
    this.isActive = true,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);

  @override
  List<Object?> get props => [
        id,
        sku,
        barcode,
        name,
        options,
        costPrice,
        sellingPrice,
        quantity,
        images,
        isActive,
      ];
}

@JsonSerializable()
class ProductAttribute extends Equatable {
  final String name;
  final String value;
  final String? displayType;

  const ProductAttribute({
    required this.name,
    required this.value,
    this.displayType,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) =>
      _$ProductAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductAttributeToJson(this);

  @override
  List<Object?> get props => [name, value, displayType];
}

@JsonSerializable()
class Dimensions extends Equatable {
  final double length;
  final double width;
  final double height;

  const Dimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) =>
      _$DimensionsFromJson(json);
  Map<String, dynamic> toJson() => _$DimensionsToJson(this);

  @override
  List<Object?> get props => [length, width, height];
}

@JsonSerializable()
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final String companyId;

  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    required this.companyId,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parentId,
        image,
        sortOrder,
        isActive,
        companyId,
      ];
}
