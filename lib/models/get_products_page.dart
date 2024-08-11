import 'package:equatable/equatable.dart';

class GetProductsPage extends Equatable {
  const GetProductsPage({
    required this.pageNumber,
  });

  final int pageNumber;

  GetProductsPage increasePageNumber() {
    return GetProductsPage(pageNumber: pageNumber + 1);
  }

  @override
  List<Object?> get props => [pageNumber];
}
