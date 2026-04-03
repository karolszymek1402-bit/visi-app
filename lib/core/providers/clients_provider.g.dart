// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientsHash() => r'23826f16cd742bdb2240a77ce7f16c930859effb';

/// `AsyncValue<List<Client>>` — reaktywny, wspierający loading/error UI.
///
/// Używaj [clientsMapProvider] wszędzie, gdzie potrzebujesz szybkiego
/// lookup'u klienta po ID (kalendarze, finanse, itp.).
///
/// Copied from [Clients].
@ProviderFor(Clients)
final clientsProvider =
    AutoDisposeAsyncNotifierProvider<Clients, List<Client>>.internal(
  Clients.new,
  name: r'clientsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$clientsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Clients = AutoDisposeAsyncNotifier<List<Client>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
