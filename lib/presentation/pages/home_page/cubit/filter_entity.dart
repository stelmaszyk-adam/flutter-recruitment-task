import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FiltersEntity extends Equatable {
  const FiltersEntity({
    this.tags,
    this.isAvailable,
    this.isFavorite,
    this.isBlurred,
    this.sellers,
    this.minRegularPrice,
    this.maxRegularPrice,
  });

  final Set<TagEntity>? tags;
  final bool? isAvailable;
  final bool? isFavorite;
  final bool? isBlurred;
  final Set<SellerEntity>? sellers;
  final double? minRegularPrice;
  final double? maxRegularPrice;

  @override
  List<Object?> get props => [
        tags,
        isAvailable,
        isFavorite,
        isBlurred,
        sellers,
        minRegularPrice,
        maxRegularPrice,
      ];
}

class TagEntity extends Equatable {
  const TagEntity({
    required this.tag,
    required this.label,
    required this.labelColor,
  });

  final String tag;
  final String label;
  final Color? labelColor;

  @override
  List<Object?> get props => [
        tag,
        label,
        labelColor,
      ];
}

class SellerEntity extends Equatable {
  const SellerEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}
