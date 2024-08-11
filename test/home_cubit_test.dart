import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  group('HomeCubit', () {
    late ProductsRepository productsRepository;
    late ProductsPage testProductsFirstPage;
    late ProductsPage testProductsSecondPage;
    late Exception exception;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      const path1 = 'assets/mocks/products_pages/1.json';
      final data1 = await rootBundle.loadString(path1);
      final json1 = jsonDecode(data1);
      testProductsFirstPage = ProductsPage.fromJson(json1);

      const path2 = 'assets/mocks/products_pages/2.json';
      final data2 = await rootBundle.loadString(path2);
      final json2 = jsonDecode(data2);
      testProductsSecondPage = ProductsPage.fromJson(json2);

      productsRepository = MockProductsRepository();

      [testProductsFirstPage.products, testProductsSecondPage.products].expand((list) => list).toList();
    });

    blocTest<HomeCubit, HomeState>(
      'successfully getNextPage',
      setUp: () {
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        HomeLoadedState(products: testProductsFirstPage.products),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'failure getNextPage',
      setUp: () {
        exception = Exception();
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenThrow(exception);
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        HomeErrorState(error: exception),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'successfully findItemById with id which belongs to first of the page',
      setUp: () {
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.findItemById(testProductsFirstPage.products.first.id);
      },
      expect: () => [
        HomeLoadedState(products: testProductsFirstPage.products),
        HomeFoundIdLoadedState(
          previousState: HomeLoadedState(
            products: testProductsFirstPage.products,
          ),
          foundIndex: [testProductsFirstPage.products]
              .expand((list) => list)
              .toList()
              .indexOf(testProductsFirstPage.products.first),
        ),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'failure findItemById',
      setUp: () {
        exception = Exception();
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenThrow(
          exception,
        );
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.findItemById(testProductsSecondPage.products.last.id);
      },
      expect: () => [
        HomeLoadedState(products: testProductsFirstPage.products),
        HomeErrorState(error: exception),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'success fetchAllDataForFilters',
      setUp: () {
        exception = Exception();
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );

        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );

        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 3))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.fetchAllDataForFilters();
      },
      expect: () => [
        HomeLoadedState(products: testProductsFirstPage.products),
        HomeErrorState(error: exception),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'failure fetchAllDataForFilters',
      setUp: () {
        exception = Exception();
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenThrow(
          exception,
        );
      },
      build: () => HomeCubit(
        productsRepository,
      ),
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.fetchAllDataForFilters();
      },
      expect: () => [
        HomeLoadedState(products: testProductsFirstPage.products),
        HomeFiltersLoadingState(HomeLoadedState(products: testProductsFirstPage.products)),
        HomeErrorState(error: exception),
      ],
      verify: (_) {
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(productsRepository);
      },
      tearDown: () => {},
      tags: [
        'logic',
      ],
    );
  });
}
