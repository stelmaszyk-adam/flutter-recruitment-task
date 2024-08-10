import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/extension/color_extension.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomeContentView extends StatefulWidget {
  const HomeContentView({required this.state, super.key});

  final HomeLoadedState state;

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
                icon: const Icon(Icons.search),
              )
            ],
          ),
      },
      body: _Content(
        state: widget.state,
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.state});

  final HomeLoadedState state;

  @override
  State<_Content> createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  final scrollController = ScrollController();

  late final SliverObserverController observerController = SliverObserverController(controller: scrollController);

  BuildContext? _sliverListCtx;

  @override
  Widget build(BuildContext context) {
    final products = widget.state.pages.map((page) => page.products).expand((product) => product).toList();

    return Padding(
      padding: _mainPadding,
      child: SliverViewObserver(
        controller: observerController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            BlocListener<HomeCubit, HomeState>(
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
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: products.length,
                  (ctx, index) {
                    _sliverListCtx ??= ctx;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ProductCard(
                          products[index],
                        ),
                        index == products.length - 1 ? const SizedBox() : const Divider()
                      ],
                    );
                  },
                ),
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
    );
  }
}

class _Search extends StatelessWidget {
  _Search();

  static const _debounceDuration = Duration(milliseconds: 1000);

  final Debouncer _debouncer = Debouncer();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
      onChanged: (value) => _debouncer.debounce(
        duration: _debounceDuration,
        onDebounce: () => context.read<HomeCubit>().findItemById(value),
      ),
    );
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
      child: TextButton(
        onPressed: context.read<HomeCubit>().getNextPage,
        child: const BigText('Get next page'),
      ),
    );
  }
}
