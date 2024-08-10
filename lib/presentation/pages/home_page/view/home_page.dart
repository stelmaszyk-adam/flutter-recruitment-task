import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_content_view.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_error_view.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/view/home_loading_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return switch (state) {
          HomeErrorState() => HomeErrorView(state: state),
          HomeLoadingState() => const HomeLoadingView(),
          HomeLoadedState() => HomeContentView(state: state),
        };
      },
    );
  }
}
