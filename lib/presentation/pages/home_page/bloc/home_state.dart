part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({
    required this.products,
    this.initFilters,
    this.currentFilters,
  });

  final List<Product> products;
  final FiltersEntity? initFilters;
  final FiltersEntity? currentFilters;

  @override
  List<Object?> get props => [
        products,
        initFilters,
        currentFilters,
      ];
}

class HomeFiltersLoadingState extends HomeLoadedState {
  HomeFiltersLoadingState(HomeLoadedState data)
      : super(
          products: data.products,
          initFilters: data.initFilters,
          currentFilters: data.currentFilters,
        );
}

class HomeFiltersLoadedState extends HomeLoadedState {
  const HomeFiltersLoadedState({
    required super.products,
    required super.initFilters,
    required super.currentFilters,
  });
}

class HomeFoundIdLoadedState extends HomeLoadedState {
  HomeFoundIdLoadedState({
    required HomeLoadedState previousState,
    required this.foundIndex,
  }) : super(
          products: previousState.products,
          initFilters: previousState.initFilters,
          currentFilters: previousState.currentFilters,
        );

  final int foundIndex;

  @override
  List<Object?> get props => [
        super.props,
        foundIndex,
      ];
}

class HomeErrorState extends HomeState {
  const HomeErrorState({required this.error});

  final Object? error;

  @override
  List<Object?> get props => [error];
}
