import '../../domain/entities/transaction_page.dart';
import 'transaction_model.dart';

class TransactionPageModel extends TransactionPage {
  const TransactionPageModel({
    required super.items,
    required super.page,
    required super.totalPages,
    required super.totalElements,
    required super.last,
  });

  /// Shape de `Page<T>` de Spring Data: {content, number, totalPages, totalElements, last, ...}.
  factory TransactionPageModel.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] as List<dynamic>? ?? [])
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return TransactionPageModel(
      items: content,
      page: (json['number'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? content.length,
      last: json['last'] as bool? ?? true,
    );
  }
}
