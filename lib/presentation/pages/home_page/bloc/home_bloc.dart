import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/models/entities/filter_entity.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._productsRepository) : super(const HomeLoadingState()) {
    on<GetNextPageHomeEvent>(
      _getNextPage,
    );
    on<FindItemByIdHomeEvent>(
      _findItemById,
      transformer: restartable(),
    );
    on<FetchAllDataForFiltersHomeEvent>(_fetchAllDataForFilters);
    on<SetNewFiltersHomeEvent>(_setNewFilters);
  }

  final ProductsRepository _productsRepository;

  Future<void> _getNextPage(
    GetNextPageHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _getInternalNextPage(emit);
  }

  Future<void> _getInternalNextPage(
    Emitter<HomeState> emit,
  ) async {
    try {
      if (isLastPage) return;
      List<Product> products = [];
      List<ProductsPage> pages = [];
      int pageIndex = 1;

      if (state case HomeLoadedState data) {
        pageIndex = data.pageIndex;
        pages = List.from(data.pages);
        products = List.from(data.products);
      }
      final newPage = await _productsRepository.getProductsPage(pageIndex);

      emit(
        HomeLoadedState(
          products: products..addAll(newPage.products),
          pages: pages..add(newPage),
          pageIndex: ++pageIndex,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(error: e));
    }
  }

  Future<void> _findItemById(
    FindItemByIdHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.id.isEmpty) {
      return;
    }
    if (state case HomeLoadedState data) {
      int index = 0;

      for (final Product product in data.products) {
        if (product.id == event.id) {
          emit(HomeFoundIdLoadedState(
            foundIndex: index,
            previousState: data,
          ));
          return;
        }
        index++;
      }

      while (!isLastPage) {
        await _getInternalNextPage(emit);

        if (state is HomeErrorState) {
          return;
        } else if (state case HomeLoadedState data) {
          for (final Product product in data.pages.last.products) {
            if (product.id == event.id) {
              emit(HomeFoundIdLoadedState(
                foundIndex: index,
                previousState: data,
              ));
              return;
            }
            index++;
          }
        }
      }

      if (state case HomeFoundIdLoadedState data) {
        emit(HomeLoadedState(
          currentFilters: data.currentFilters,
          initFilters: data.initFilters,
          products: data.products,
          pages: data.pages,
          pageIndex: data.pageIndex,
        ));
      }
    }
  }

  bool get isLastPage {
    if (state case HomeLoadedState data) {
      final totalPages = data.pages.lastOrNull?.totalPages;

      return totalPages != null && data.pageIndex > totalPages;
    } else {
      return false;
    }
  }

  Future<void> _fetchAllDataForFilters(
    FetchAllDataForFiltersHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state case HomeLoadedState data) {
      emit(HomeFiltersLoadingState(data));

      if (data.initFilters == null) {
        List<Product> products = List.from(data.products);
        List<ProductsPage> pages = List.from(data.pages);
        int pageIndex = data.pageIndex;

        while (!(pageIndex > (pages.lastOrNull?.totalPages ?? 0))) {
          try {
            final newPage = await _productsRepository.getProductsPage(pageIndex);
            pageIndex++;
            pages.add(newPage);
            products.addAll(newPage.products);
          } catch (e) {
            emit(HomeErrorState(error: e));
            return;
          }
        }

        Set<TagEntity> tags = {};
        Set<SellerEntity> sellers = {};
        const noValue = -1.0;
        double minRegularPrice = noValue;
        double maxRegularPrice = noValue;

        for (final page in pages) {
          for (final product in page.products) {
            tags.addAll(product.tags.map((tag) => tag.toEntity()).toSet());
            sellers.add(SellerEntity(id: product.sellerId, name: product.offer.sellerName));

            if (minRegularPrice == noValue || minRegularPrice > product.offer.regularPrice.amount) {
              minRegularPrice = product.offer.regularPrice.amount;
            }

            if (maxRegularPrice == noValue || maxRegularPrice < product.offer.regularPrice.amount) {
              maxRegularPrice = product.offer.regularPrice.amount;
            }
          }
        }
        emit(HomeFiltersLoadedState(
          products: products,
          pageIndex: pageIndex,
          pages: pages,
          initFilters: FiltersEntity(
            tags: tags,
            sellers: sellers,
            maxRegularPrice: maxRegularPrice,
            minRegularPrice: minRegularPrice,
          ),
          currentFilters: data.currentFilters,
        ));
      } else {
        emit(HomeFiltersLoadedState(
          products: data.products,
          initFilters: data.initFilters,
          currentFilters: data.currentFilters,
          pageIndex: data.pageIndex,
          pages: data.pages,
        ));
      }
    }
  }

  void _setNewFilters(
    SetNewFiltersHomeEvent event,
    Emitter<HomeState> emit,
  ) {
    final newFilters = event.newFilters;
    if (newFilters == null) {
      return;
    }

    if (state case HomeLoadedState data) {
      emit(const HomeLoadingState());

      final List<Product> newProducts = [];

      Set<String> tagsId = newFilters.tags?.map((tag) => tag.tag).toSet() ?? {};
      Set<String> sellersId = newFilters.sellers?.map((tag) => tag.id).toSet() ?? {};

      for (final page in data.pages) {
        for (final product in page.products) {
          if (newFilters.isAvailable != null && newFilters.isAvailable != product.available) {
            continue;
          }

          if (newFilters.isBlurred != null && newFilters.isBlurred != product.isBlurred) {
            continue;
          }

          if (newFilters.isFavorite != null && newFilters.isFavorite != product.isFavorite) {
            continue;
          }

          if (newFilters.minRegularPrice != null && newFilters.minRegularPrice! > product.offer.regularPrice.amount) {
            continue;
          }

          if (newFilters.maxRegularPrice != null && newFilters.maxRegularPrice! < product.offer.regularPrice.amount) {
            continue;
          }

          if (tagsId.isNotEmpty && !product.tags.any((tag) => tagsId.contains(tag.tag))) {
            continue;
          }

          if (sellersId.isNotEmpty && !sellersId.contains(product.sellerId)) {
            continue;
          }

          newProducts.add(product);
        }
      }
      emit(HomeLoadedState(
        currentFilters: newFilters,
        initFilters: data.initFilters,
        products: newProducts,
        pageIndex: data.pageIndex,
        pages: data.pages,
      ));
    }
  }
}
