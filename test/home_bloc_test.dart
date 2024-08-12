import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/models/entities/filter_entity.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/bloc/home_bloc.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

part 'home_bloc_test.helper.dart';

void main() {
  final params = _HomeBlocTestHelper();
  group('HomeBloc - ', () {
    setUpAll(() => params.setUpAll());

    setUp(() => params.setUp());

    blocTest<HomeBloc, HomeState>(
      'success GetNextPageHomeEvent',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            params.testProductsFirstPage,
          ),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) => bloc.add(const GetNextPageHomeEvent()),
      expect: () => [
        HomeLoadedState(products: params.testProductsFirstPage.products),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'failure GetNextPageHomeEvent',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)))
            .thenThrow(params.exception);
      },
      build: () => params.homeBloc,
      act: (bloc) => bloc.add(const GetNextPageHomeEvent()),
      expect: () => [
        HomeErrorState(error: params.exception),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success HomeFoundIdLoadedState - product id belongs to first page of the items',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            params.testProductsFirstPage,
          ),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(FindItemByIdHomeEvent(id: params.testProductsFirstPage.products.first.id));
      },
      expect: () => [
        HomeLoadedState(products: params.testProductsFirstPage.products),
        HomeFoundIdLoadedState(
          previousState: HomeLoadedState(
            products: params.testProductsFirstPage.products,
          ),
          foundIndex: [params.testProductsFirstPage.products]
              .expand((list) => list)
              .toList()
              .indexOf(params.testProductsFirstPage.products.first),
        ),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success HomeFoundIdLoadedState - product id belongs to second page of the items',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            params.testProductsFirstPage,
          ),
        );

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenAnswer(
          (_) => Future.value(
            params.testProductsSecondPage,
          ),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(FindItemByIdHomeEvent(id: params.testProductsSecondPage.products.first.id));
      },
      expect: () => [
        isA<HomeLoadedState>(),
        isA<HomeLoadedState>(),
        isA<HomeFoundIdLoadedState>(),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success FindItemByIdHomeEvent,add event, after it tries again and next id does not exist in the pages and bloc come back to HomeLoadedState state -  downloading the next pages from backend',
      setUp: () {
        const product = ProductsPage(
          pageNumber: 1,
          totalPages: 1,
          pageSize: 1,
          products: [
            Product(
              available: false,
              id: '123',
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

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            product,
          ),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(const FindItemByIdHomeEvent(id: '123'))
          ..add(const FindItemByIdHomeEvent(id: '1'));
      },
      expect: () => [
        isA<HomeLoadedState>(),
        isA<HomeFoundIdLoadedState>(),
        isA<HomeLoadedState>(),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success FindItemByIdHomeEvent,add event, after it tries again and next id does not exist in the pages and bloc come back to HomeLoadedState state - case without downloading the next pages from backend',
      setUp: () {
        const product = ProductsPage(
          pageNumber: 1,
          totalPages: 2,
          pageSize: 1,
          products: [
            Product(
              available: false,
              id: '123',
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

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            product,
          ),
        );

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenAnswer(
          (_) => Future.value(
            product,
          ),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(const FindItemByIdHomeEvent(id: '123'))
          ..add(const FindItemByIdHomeEvent(id: '1'));
      },
      expect: () => [
        isA<HomeLoadedState>(),
        isA<HomeFoundIdLoadedState>(),
        isA<HomeLoadedState>(),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'failure FindItemByIdHomeEvent',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            params.testProductsFirstPage,
          ),
        );
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenThrow(
          params.exception,
        );
      },
      build: () => params.homeBloc,
      act: (bloc) async {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(FindItemByIdHomeEvent(id: params.testProductsSecondPage.products.first.id));
      },
      expect: () => [
        HomeLoadedState(products: params.testProductsFirstPage.products),
        HomeErrorState(error: params.exception),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success FetchAllDataForFiltersHomeEvent, run one time FetchAllDataForFiltersHomeEvent and try again run FetchAllDataForFiltersHomeEvent',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(params.filtersProductPage),
        );

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenAnswer(
          (_) => Future.value(params.filtersProductPage),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) async {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(const FetchAllDataForFiltersHomeEvent())
          ..add(const FetchAllDataForFiltersHomeEvent());
      },
      expect: () => [
        HomeLoadedState(products: params.filtersProductPage.products),
        HomeFiltersLoadingState(HomeLoadedState(products: params.filtersProductPage.products)),
        HomeFiltersLoadedState(
          currentFilters: null,
          products: [params.filtersProductPage.products[0], params.filtersProductPage.products[0]],
          initFilters: FiltersEntity(
            tags: const {},
            sellers: {
              SellerEntity(
                id: params.filtersProductPage.products[0].sellerId,
                name: params.filtersProductPage.products[0].offer.sellerName,
              )
            },
            maxRegularPrice: params.filtersProductPage.products[0].offer.regularPrice.amount,
            minRegularPrice: params.filtersProductPage.products[0].offer.regularPrice.amount,
          ),
        ),
        isA<HomeFiltersLoadingState>(),
        isA<HomeFiltersLoadedState>(),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'failure FetchAllDataForFiltersHomeEvent',
      setUp: () {
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(
            params.testProductsFirstPage,
          ),
        );
        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2))).thenThrow(
          params.exception,
        );
      },
      build: () => params.homeBloc,
      act: (bloc) async {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(const FetchAllDataForFiltersHomeEvent());
      },
      expect: () => [
        HomeLoadedState(products: params.testProductsFirstPage.products),
        HomeFiltersLoadingState(HomeLoadedState(products: params.testProductsFirstPage.products)),
        HomeErrorState(error: params.exception),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 2)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'success SetNewFiltersHomeEvent',
      setUp: () {
        const product = ProductsPage(
          pageNumber: 1,
          totalPages: 1,
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
            ),
            Product(
              available: true,
              id: '',
              name: '',
              mainImage: '',
              description: '',
              isFavorite: true,
              isBlurred: false,
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

        when(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1))).thenAnswer(
          (_) => Future.value(product),
        );
      },
      build: () => params.homeBloc,
      act: (bloc) async {
        bloc
          ..add(const GetNextPageHomeEvent())
          ..add(SetNewFiltersHomeEvent(newFilters: params.newFilters));
      },
      expect: () => [
        isA<HomeLoadedState>(),
        isA<HomeLoadingState>(),
        isA<HomeLoadedState>()
            .having((e) => e.currentFilters, 'check that newFilters was set correctly', params.newFilters),
      ],
      verify: (_) {
        verify(() => params.productsRepository.getProductsPage(const GetProductsPage(pageNumber: 1)));
        verifyNoMoreInteractions(params.productsRepository);
      },
      tags: [
        'logic',
      ],
    );
  });
}
