// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_serializer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiTransaction _$ApiTransactionFromJson(Map<String, dynamic> json) =>
    ApiTransaction(
      id: json['id'] as String,
      description: json['description'] as String?,
      amount: const AmountConverter().fromJson(json['amount']),
      notes: json['notes'] as String?,
      currency: json['currency'] as String?,
      account: json['account'] as String,
      transactionCategory: json['original_category'] as String,
      transactionType: json['type'] as String,
      transactionDate:
          ApiTransaction._parseDate(json['transactionDate'] as String),
      status: json['status'] as String?,
      considered: json['considered'] as bool,
      isOpenFinance: json['isOpenFinance'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ApiTransactionToJson(ApiTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': const AmountConverter().toJson(instance.amount),
      'notes': instance.notes,
      'currency': instance.currency,
      'account': instance.account,
      'original_category': instance.transactionCategory,
      'type': instance.transactionType,
      'transactionDate': ApiTransaction._dateToJson(instance.transactionDate),
      'status': instance.status,
      'considered': instance.considered,
      'isOpenFinance': instance.isOpenFinance,
      'tags': instance.tags,
    };
