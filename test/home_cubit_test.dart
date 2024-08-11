import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/models/entities/filter_entity.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/cubit/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  group('HomeCubit - ', () {
    late ProductsRepository productsRepository;
    late ProductsPage testProductsFirstPage;
    late ProductsPage testProductsSecondPage;
    late Exception exception;

    late HomeCubit homeCubit;

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

    setUp(() {
      homeCubit = HomeCubit(
        productsRepository,
      );
    });

    blocTest<HomeCubit, HomeState>(
      'success getNextPage',
      setUp: () {
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
      },
      build: () => homeCubit,
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
      build: () => homeCubit,
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
      'success findItemById with id which belongs to first of the page',
      setUp: () {
        when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            testProductsFirstPage,
          ),
        );
      },
      build: () => homeCubit,
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
      build: () => homeCubit,
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

    test(('success fetchAllDataForFilter and check that it is last page'), () async {
      const product = ProductsPage(
        pageNumber: 1,
        totalPages: 2,
        pageSize: 1,
        products: [
          Product(
            available: false,
            id: '',
            name: '',
            mainImage: '',
            description: '',
            isFavorite: null,
            isBlurred: null,
            sellerId: 'sellerId',
            tags: [],
            offer: Offer(
                skuId: '',
                sellerId: 'sellerId',
                normalizedPrice: null,
                subtitle: '',
                omnibusPrice: null,
                regularPrice: Price(amount: 10, currency: 'PLN'),
                isBest: null,
                isSponsored: null,
                promotionalPrice: null,
                sellerName: 'sellerName',
                promotionalNormalizedPrice: null,
                tags: [],
                omnibusLabel: ''),
          )
        ],
      );

      when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
        (_) => Future.value(product),
      );

      when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenAnswer(
        (_) => Future.value(product),
      );

      await homeCubit.getNextPage();

      expect(homeCubit.isLastPage, false);

      await homeCubit.fetchAllDataForFilters();

      expect(
        homeCubit.state,
        HomeFiltersLoadedState(
          currentFilters: null,
          products: [product.products[0], product.products[0]],
          initFilters: FiltersEntity(
            tags: const {},
            sellers: {
              SellerEntity(
                id: product.products[0].sellerId,
                name: product.products[0].offer.sellerName,
              )
            },
            maxRegularPrice: product.products[0].offer.regularPrice.amount,
            minRegularPrice: product.products[0].offer.regularPrice.amount,
          ),
        ),
      );

      expect(homeCubit.isLastPage, true);
    });

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
      build: () => homeCubit,
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

    test(('success setNewFilters'), () async {
      const filters = FiltersEntity(
        tags: {},
        isAvailable: true,
        isBlurred: false,
        isFavorite: true,
        maxRegularPrice: 100,
        minRegularPrice: 20,
        sellers: {},
      );

      const product = ProductsPage(
        pageNumber: 1,
        totalPages: 2,
        pageSize: 1,
        products: [
          Product(
            available: false,
            id: '',
            name: '',
            mainImage: '',
            description: '',
            isFavorite: null,
            isBlurred: null,
            sellerId: 'sellerId',
            tags: [],
            offer: Offer(
                skuId: '',
                sellerId: 'sellerId',
                normalizedPrice: null,
                subtitle: '',
                omnibusPrice: null,
                regularPrice: Price(amount: 10, currency: 'PLN'),
                isBest: null,
                isSponsored: null,
                promotionalPrice: null,
                sellerName: 'sellerName',
                promotionalNormalizedPrice: null,
                tags: [],
                omnibusLabel: ''),
          )
        ],
      );

      when(() => productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
        (_) => Future.value(product),
      );

      await homeCubit.getNextPage();

      expect(homeCubit.state, HomeLoadedState(products: product.products));

      homeCubit.setNewFilters(filters);

      expect(homeCubit.state, const HomeLoadedState(products: [], currentFilters: filters));
    });
  });
}
