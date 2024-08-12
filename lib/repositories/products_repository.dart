//
// Don't modify this file please!
//
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';

const _fakeDelay = Duration(milliseconds: 500);

abstract class ProductsRepository {
  Future<ProductsPage> getProductsPage(int pageIndex);
}

class MockedProductsRepository implements ProductsRepository {
  @override
  Future<ProductsPage> getProductsPage(int pageIndex) async {
    final path = 'assets/mocks/products_pages/$pageIndex.json';
    final data = await rootBundle.loadString(path);
    final json = jsonDecode(data);
    final page = ProductsPage.fromJson(json);

    return Future.delayed(_fakeDelay, () => page);
  }
}
