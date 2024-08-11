import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/extension/color_extension.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

const _mainPadding = EdgeInsets.all(16.0);
const _debounceDuration = Duration(milliseconds: 500);

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: switch (isSearch) {
        true => AppBar(
            title: _Search(),
            actions: [
              IconButton(
                onPressed: () => setState(() {
                  isSearch = !isSearch;
                }),
                icon: const Text('Close'),
              )
            ],
          ),
        false => AppBar(
            title: const BigText('Product'),
            actions: [
              IconButton(
                onPressed: () => setState(() {
                  isSearch = !isSearch;
                }),
                icon: const Icon(
                  Icons.search,
                ),
              ),
              IconButton(
                onPressed: () => context.read<HomeCubit>().fetchAllDataForFilters(),
                icon: const Icon(
                  Icons.filter_alt_sharp,
                ),
              ),
            ],
          ),
      },
      body: const _Content(),
    );
  }
}

class _Search extends StatelessWidget {
  _Search();

  final Debouncer _debouncer = Debouncer();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
      onChanged: (value) => _debouncer.debounce(
        duration: _debounceDuration,
        onDebounce: () => context.read<HomeCubit>().findItemById(value),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final scrollController = ScrollController();

  late final SliverObserverController observerController = SliverObserverController(controller: scrollController);

  BuildContext? _sliverListCtx;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) => previous is HomeLoadedState && current is HomeFoundIdLoadedState,
        listener: (context, state) {
          if (state case HomeFoundIdLoadedState data) {
            observerController.animateTo(
              index: data.foundIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        builder: (context, state) => switch (state) {
              HomeLoadedState() => Padding(
                  padding: _mainPadding,
                  child: SliverViewObserver(
                    controller: observerController,
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: state.products.length,
                            (ctx, index) {
                              _sliverListCtx ??= ctx;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ProductCard(
                                    state.products[index],
                                  ),
                                  index == state.products.length - 1 ? const SizedBox() : const Divider()
                                ],
                              );
                            },
                          ),
                        ),
                        const _GetNextPageButton(),
                      ],
                    ),
                    sliverContexts: () {
                      return [
                        if (_sliverListCtx != null) _sliverListCtx!,
                      ];
                    },
                  ),
                ),
              _ => const SizedBox.shrink()
            });
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('id: ${product.id}'),
            BigText(product.name),
            _Tags(product: product),
          ],
        ),
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: product.tags
          .map((tag) => _TagWidget(
                tag,
              ))
          .toList(),
    );
  }
}

class _TagWidget extends StatelessWidget {
  const _TagWidget(this.tag);

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        color: WidgetStateProperty.all(tag.labelColor.toColor()),
        label: Text(tag.label),
      ),
    );
  }
}

class _GetNextPageButton extends StatelessWidget {
  const _GetNextPageButton();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: switch (context.watch<HomeCubit>().isLastPage) {
        true => const SizedBox(),
        false => TextButton(
            onPressed: context.read<HomeCubit>().getNextPage,
            child: const BigText('Get next page'),
          ),
      },
    );
  }
}
