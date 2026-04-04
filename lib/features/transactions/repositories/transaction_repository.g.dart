// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseServiceHash() => r'766f41a8fb8947216fae68bbc31fa62d037f6899';

/// See also [databaseService].
@ProviderFor(databaseService)
final databaseServiceProvider = AutoDisposeProvider<DatabaseService>.internal(
  databaseService,
  name: r'databaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseServiceRef = AutoDisposeProviderRef<DatabaseService>;
String _$transactionRepositoryHash() =>
    r'e5c7649b8043e0d8978e5b1006d29522098e105f';

/// See also [TransactionRepository].
@ProviderFor(TransactionRepository)
final transactionRepositoryProvider = AutoDisposeAsyncNotifierProvider<
    TransactionRepository, TransactionRepository>.internal(
  TransactionRepository.new,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionRepository
    = AutoDisposeAsyncNotifier<TransactionRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
