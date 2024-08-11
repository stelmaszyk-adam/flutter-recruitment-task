import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/presentation/pages/filters_page/view/filters_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/filter_entity.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_content_view.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_error_view.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_loading_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        return previous is HomeFiltersLoadingState && current is HomeFiltersLoadedState;
      },
      listener: (context, state) async => switch (state) {
        HomeFiltersLoadedState() => {
            Navigator.push<FiltersEntity?>(
              context,
              MaterialPageRoute(
                builder: (context) => FiltersPage(
                  initFilters: state.initFilters,
                  currentFilters: state.currentFilters,
                ),
              ),
            ).then((value) => context.read<HomeCubit>().setNewCurrentFilters(value))
          },
        _ => {},
      },
      builder: (context, state) {
        return switch (state) {
          HomeErrorState() => HomeErrorView(state: state),
          HomeLoadingState() || HomeFiltersLoadingState() => const HomeLoadingView(),
          HomeLoadedState() => const HomeContentView(),
        };
      },
    );
  }
}
