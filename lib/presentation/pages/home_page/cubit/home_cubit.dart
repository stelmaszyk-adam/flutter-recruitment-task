import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/models/filter_entity.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const HomeLoadingState());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = const GetProductsPage(pageNumber: 1);

  Future<void> getNextPage() async {
    try {
      if (isLastPage) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(HomeLoadedState(products: _pages.map((pages) => pages.products).expand((product) => product).toList()));
    } catch (e) {
      emit(HomeErrorState(error: e));
    }
  }

  Future<void> findItemById(String id) async {
    if (state case HomeLoadedState data) {
      int index = 0;

      for (final Product product in data.products) {
        if (product.id == id) {
          emit(HomeFoundIdLoadedState(
            foundIndex: index,
            previousState: data,
          ));
          return;
        }
        index++;
      }

      while (!isLastPage) {
        await getNextPage();

        for (final Product product in _pages.last.products) {
          if (product.id == id) {
            emit(HomeFoundIdLoadedState(
              foundIndex: index,
              previousState: data,
            ));
            return;
          }
          index++;
        }
      }

      if (state is HomeFoundIdLoadedState) {
        emit(HomeLoadedState(
          currentFilters: data.currentFilters,
          initFilters: data.initFilters,
          products: data.products,
        ));
      }
    }
  }

  bool get isLastPage {
    final totalPages = _pages.lastOrNull?.totalPages;

    return totalPages != null && _param.pageNumber > totalPages;
  }

  Future<void> fetchAllDataForFilters() async {
    if (state case HomeLoadedState data) {
      emit(HomeFiltersLoadingState(data));

      if (data.initFilters == null) {
        while (!isLastPage) {
          try {
            final newPage = await _productsRepository.getProductsPage(_param);
            _param = _param.increasePageNumber();
            _pages.add(newPage);
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

        for (final pages in _pages) {
          for (final product in pages.products) {
            tags.addAll(product.tags.map((tag) => tag.toEntity()).toSet());
            sellers.add(SellerEntity(id: product.sellerId, name: product.offer.sellerName));

            if (product.offer.normalizedPrice?.amount != null &&
                (minRegularPrice == noValue || minRegularPrice > product.offer.normalizedPrice!.amount)) {
              minRegularPrice = product.offer.normalizedPrice!.amount;
            }

            if (product.offer.normalizedPrice?.amount != null &&
                (maxRegularPrice == noValue || maxRegularPrice < product.offer.normalizedPrice!.amount)) {
              maxRegularPrice = product.offer.normalizedPrice!.amount;
            }
          }
        }
        final products = _pages.map((pages) => pages.products).expand((product) => product).toList();
        emit(HomeFiltersLoadedState(
          products: products,
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
        ));
      }
    }
  }

  void setNewCurrentFilters(FiltersEntity? newCurrentFilters) {
    if (newCurrentFilters == null) {
      return;
    }

    if (state case HomeLoadedState data) {
      emit(const HomeLoadingState());

      final List<Product> newProducts = [];

      Set<String> tagsId = newCurrentFilters.tags?.map((tag) => tag.tag).toSet() ?? {};
      Set<String> sellersId = newCurrentFilters.sellers?.map((tag) => tag.id).toSet() ?? {};

      for (final pages in _pages) {
        for (final product in pages.products) {
          if (newCurrentFilters.isAvailable != null && newCurrentFilters.isAvailable != product.available) {
            continue;
          }

          if (newCurrentFilters.isBlurred != null && newCurrentFilters.isBlurred != product.isBlurred) {
            continue;
          }

          if (newCurrentFilters.isFavorite != null && newCurrentFilters.isFavorite != product.isFavorite) {
            continue;
          }

          if (newCurrentFilters.minRegularPrice != null &&
              newCurrentFilters.minRegularPrice! > product.offer.regularPrice.amount) {
            continue;
          }

          if (newCurrentFilters.maxRegularPrice != null &&
              newCurrentFilters.maxRegularPrice! < product.offer.regularPrice.amount) {
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
        currentFilters: newCurrentFilters,
        initFilters: data.initFilters,
        products: newProducts,
      ));
    }
  }
}
