// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientRepositoryHash() => r'565f4309f64c4f89bf6de66f36777604e0d899a2';

/// Pojedyncze źródło prawdy dla operacji CRUD na klientach.
///
/// Enkapsuluje:
///  - odczyt z Hive (offline-first, synchroniczny)
///  - zapis do Hive + natychmiastowa próba sync z Firestore
///  - kolejkowanie operacji gdy brak połączenia
///
/// Copied from [clientRepository].
@ProviderFor(clientRepository)
final clientRepositoryProvider = AutoDisposeProvider<ClientRepository>.internal(
  clientRepository,
  name: r'clientRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClientRepositoryRef = AutoDisposeProviderRef<ClientRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
