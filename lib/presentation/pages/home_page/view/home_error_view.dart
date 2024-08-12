import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/bloc/home_bloc.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({required this.state, super.key});

  final HomeErrorState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Products'),
      ),
      body: BigText('Error: ${state.error}'),
    );
  }
}
