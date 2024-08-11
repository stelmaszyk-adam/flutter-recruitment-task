import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Products'),
      ),
      body: const Center(child: BigText('Loading...')),
    );
  }
}
