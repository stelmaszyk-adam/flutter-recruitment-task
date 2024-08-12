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
    required this.pages,
    this.initFilters,
    this.currentFilters,
    required this.pageIndex,
  });

  final List<Product> products;
  final List<ProductsPage> pages;
  final FiltersEntity? initFilters;
  final FiltersEntity? currentFilters;
  final int pageIndex;

  @override
  List<Object?> get props => [
        products,
        initFilters,
        currentFilters,
        pages,
        pageIndex,
      ];
}

class HomeFiltersLoadingState extends HomeLoadedState {
  HomeFiltersLoadingState(HomeLoadedState data)
      : super(
          products: data.products,
          pages: data.pages,
          initFilters: data.initFilters,
          currentFilters: data.currentFilters,
          pageIndex: data.pageIndex,
        );
}

class HomeFiltersLoadedState extends HomeLoadedState {
  const HomeFiltersLoadedState({
    required super.products,
    required super.pages,
    required super.initFilters,
    required super.currentFilters,
    required super.pageIndex,
  });
}

class HomeFoundIdLoadedState extends HomeLoadedState {
  HomeFoundIdLoadedState({
    required HomeLoadedState previousState,
    required this.foundIndex,
  }) : super(
          products: previousState.products,
          pages: previousState.pages,
          initFilters: previousState.initFilters,
          currentFilters: previousState.currentFilters,
          pageIndex: previousState.pageIndex,
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
