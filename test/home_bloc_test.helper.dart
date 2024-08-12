part of 'home_bloc_test.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

class _HomeBlocTestHelper {
  late final ProductsRepository productsRepository;
  late final ProductsPage testProductsFirstPage;
  late final ProductsPage testProductsSecondPage;
  late final Exception exception;

  late HomeBloc homeBloc;

  Future<void> setUpAll() async {
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

    exception = Exception();
  }

  void setUp() {
    homeBloc = HomeBloc(
      productsRepository,
    );
  }

  final filtersProductPage = const ProductsPage(
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

  final newFilters = const FiltersEntity(
    tags: {},
    isAvailable: true,
    isBlurred: false,
    isFavorite: true,
    maxRegularPrice: 100,
    minRegularPrice: 0,
    sellers: {},
  );
}
