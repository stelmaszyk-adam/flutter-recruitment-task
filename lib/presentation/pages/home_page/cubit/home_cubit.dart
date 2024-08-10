import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const HomeLoadingState());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  Future<void> getNextPage() async {
    try {
      if (_isLastPage) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(HomeLoadedState(pages: _pages));
    } catch (e) {
      emit(HomeErrorState(error: e));
    }
  }

  Future<void> findItemById(String id) async {
    if (state case HomeLoadedState data) {
      // emit(SearchingIdLoaded(pages: data.pages));
      int index = 0;

      for (final page in data.pages) {
        for (final Product product in page.products) {
          if (product.id == id) {
            emit(HomeFoundIdLoadedState(foundIndex: index, pages: data.pages));
          }
          index++;
        }
      }

      while (!_isLastPage) {
        await getNextPage();

        for (final Product product in data.pages.last.products) {
          if (product.id == id) {
            emit(HomeFoundIdLoadedState(foundIndex: index, pages: data.pages));
          }
          index++;
        }
      }
    }
  }

  bool get _isLastPage {
    final totalPages = _pages.lastOrNull?.totalPages;

    return totalPages != null && _param.pageNumber > totalPages;
  }
}
