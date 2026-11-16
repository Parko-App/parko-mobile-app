import 'package:equatable/equatable.dart';
import 'transaction.dart';

class TransactionPage extends Equatable {
  final List<Transaction> items;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool last;

  const TransactionPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  static const empty = TransactionPage(
    items: [],
    page: 0,
    totalPages: 1,
    totalElements: 0,
    last: true,
  );

  @override
  List<Object?> get props => [items, page, totalPages, totalElements, last];
}
