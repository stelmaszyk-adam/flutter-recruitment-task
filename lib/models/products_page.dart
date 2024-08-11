import 'package:equatable/equatable.dart';
import 'package:flutter_recruitment_task/presentation/extension/color_extension.dart';
import 'package:flutter_recruitment_task/models/entities/filter_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'products_page.g.dart';

@JsonSerializable()
class ProductsPage extends Equatable {
  const ProductsPage({
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.products,
  });

  factory ProductsPage.fromJson(Map<String, dynamic> json) => _$ProductsPageFromJson(json);

  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final List<Product> products;

  @override
  List<Object?> get props => [
        pageNumber,
        pageSize,
        totalPages,
        products,
      ];
}

@JsonSerializable()
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.mainImage,
    required this.description,
    required this.available,
    required this.isFavorite,
    required this.isBlurred,
    required this.sellerId,
    required this.tags,
    required this.offer,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  final String id;
  final String name;
  final String mainImage;
  final String description;
  final bool available;
  final bool? isFavorite;
  final bool? isBlurred;
  final String sellerId;
  final List<Tag> tags;
  final Offer offer;

  @override
  List<Object?> get props => [
        id,
        name,
        mainImage,
        description,
        available,
        isFavorite,
        isBlurred,
        sellerId,
        tags,
        offer,
      ];
}

@JsonSerializable()
class Offer extends Equatable {
  const Offer({
    required this.skuId,
    required this.sellerId,
    required this.sellerName,
    required this.subtitle,
    required this.isSponsored,
    required this.isBest,
    required this.regularPrice,
    required this.promotionalPrice,
    required this.normalizedPrice,
    required this.promotionalNormalizedPrice,
    required this.omnibusPrice,
    required this.omnibusLabel,
    required this.tags,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  final String skuId;
  final String sellerId;
  final String sellerName;
  final String subtitle;
  final bool? isSponsored;
  final bool? isBest;
  final Price regularPrice;
  final Price? promotionalPrice;
  final NormalizedPrice? normalizedPrice;
  final NormalizedPrice? promotionalNormalizedPrice;
  final Price? omnibusPrice;
  final String? omnibusLabel;
  final List<Tag>? tags;

  @override
  List<Object?> get props => [
        skuId,
        sellerId,
        sellerName,
        subtitle,
        isSponsored,
        isBest,
        regularPrice,
        promotionalPrice,
        normalizedPrice,
        promotionalNormalizedPrice,
        omnibusPrice,
        omnibusLabel,
        tags,
      ];
}

@JsonSerializable()
class Tag extends Equatable {
  const Tag({
    required this.tag,
    required this.label,
    required this.color,
    required this.labelColor,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  final String tag;
  final String label;
  final String color;
  final String labelColor;

  TagEntity toEntity() {
    return TagEntity(
      label: label,
      labelColor: labelColor.toColor(),
      tag: tag,
    );
  }

  @override
  List<Object?> get props => [
        tag,
        label,
        color,
        labelColor,
      ];
}

@JsonSerializable()
class Price extends Equatable {
  const Price({
    required this.amount,
    required this.currency,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  final double amount;
  final String currency;

  @override
  List<Object?> get props => [
        amount,
        currency,
      ];
}

@JsonSerializable()
class NormalizedPrice extends Equatable {
  const NormalizedPrice({
    required this.amount,
    required this.currency,
    required this.unitLabel,
  });

  factory NormalizedPrice.fromJson(Map<String, dynamic> json) => _$NormalizedPriceFromJson(json);

  final double amount;
  final String currency;
  final String? unitLabel;

  @override
  List<Object?> get props => [
        amount,
        currency,
        unitLabel,
      ];
}
