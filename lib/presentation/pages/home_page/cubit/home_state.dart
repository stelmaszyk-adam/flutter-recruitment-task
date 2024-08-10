part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({required this.pages});

  final List<ProductsPage> pages;
}

class HomeSearchingIdLoadedState extends HomeLoadedState {
  const HomeSearchingIdLoadedState({
    required super.pages,
  });
}

class HomeFoundIdLoadedState extends HomeLoadedState {
  const HomeFoundIdLoadedState({
    required super.pages,
    required this.foundIndex,
  });

  final int foundIndex;
}

class HomeErrorState extends HomeState {
  const HomeErrorState({required this.error});

  final dynamic error;
}
