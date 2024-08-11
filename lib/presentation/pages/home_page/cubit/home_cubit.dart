import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/models/entities/filter_entity.dart';
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
    if (id.isEmpty) {
      return;
    }
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

        if (state is HomeErrorState) {
          return;
        } else if (state case HomeLoadedState data) {
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
      }

      if (state case HomeFoundIdLoadedState data) {
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

            if (minRegularPrice == noValue || minRegularPrice > product.offer.regularPrice.amount) {
              minRegularPrice = product.offer.regularPrice.amount;
            }

            if (maxRegularPrice == noValue || maxRegularPrice < product.offer.regularPrice.amount) {
              maxRegularPrice = product.offer.regularPrice.amount;
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

  void setNewFilters(FiltersEntity? newFilters) {
    if (newFilters == null) {
      return;
    }

    if (state case HomeLoadedState data) {
      emit(const HomeLoadingState());

      final List<Product> newProducts = [];

      Set<String> tagsId = newFilters.tags?.map((tag) => tag.tag).toSet() ?? {};
      Set<String> sellersId = newFilters.sellers?.map((tag) => tag.id).toSet() ?? {};

      for (final pages in _pages) {
        for (final product in pages.products) {
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
      ));
    }
  }
}
