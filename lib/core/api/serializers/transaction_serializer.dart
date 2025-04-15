import 'package:json_annotation/json_annotation.dart';

part 'transaction_serializer.g.dart';

/// Custom converter to handle the 'amount' field, which can be either a String or a num.
class AmountConverter implements JsonConverter<double, dynamic> {
  const AmountConverter();

  @override
  double fromJson(dynamic json) {
    if (json is num) {
      return json.toDouble();
    } else if (json is String) {
      return double.tryParse(json) ?? 0.0;
    } else {
      // Optionally, throw an exception or handle as needed
      return 0.0;
    }
  }

  @override
  dynamic toJson(double object) => object;
}

@JsonSerializable()
class ApiTransaction {
  final String id;
  final String? description;

  @AmountConverter()
  final double amount;

  final String? notes;
  final String? currency;

  final String account;

  @JsonKey(name: 'original_category')
  final String transactionCategory;

  @JsonKey(name: 'type')
  final String transactionType;

  @JsonKey(
    fromJson: _parseDate,
    toJson: _dateToJson,
  )
  final DateTime transactionDate;

  final String? status;

  final bool considered;

  final bool isOpenFinance;

  final int? cousin;

  final List<String> tags; // Add this line

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  final bool? manipulated;

  @JsonKey(name: 'lastUpdateDateParsa')
  final DateTime? lastUpdateTime;

  ApiTransaction({
    required this.id,
    this.description,
    required this.amount,
    this.notes,
    this.currency,
    required this.account,
    required this.transactionCategory,
    required this.transactionType,
    required this.transactionDate,
    this.status,
    required this.considered,
    required this.isOpenFinance,
    required this.tags,
    this.paymentMethod,
    this.manipulated,
    this.lastUpdateTime,
    this.cousin,
  });

  /// Factory constructor for creating a new `ApiTransaction` instance from JSON.
  factory ApiTransaction.fromJson(Map<String, dynamic> json) =>
      _$ApiTransactionFromJson(json);

  /// Converts the `ApiTransaction` instance to JSON.
  Map<String, dynamic> toJson() => _$ApiTransactionToJson(this);

  /// Custom method to parse DateTime with error handling.
  static DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Invalid date format: $dateStr. Using current date instead.');
      return DateTime.now();
    }
  }

  /// Custom method to convert DateTime to JSON string.
  static String _dateToJson(DateTime date) => date.toIso8601String();
}
