part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class GetNextPageHomeEvent extends HomeEvent {
  const GetNextPageHomeEvent();
}

class FindItemByIdHomeEvent extends HomeEvent {
  const FindItemByIdHomeEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class FetchAllDataForFiltersHomeEvent extends HomeEvent {
  const FetchAllDataForFiltersHomeEvent();
}

class SetNewFiltersHomeEvent extends HomeEvent {
  const SetNewFiltersHomeEvent({
    required this.newFilters,
  });

  final FiltersEntity? newFilters;

  @override
  List<Object?> get props => [newFilters];
}
