// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$financeTotalBalanceHash() =>
    r'af46777a4859cda1c7664b441f9e3978e7a72d30';

/// See also [financeTotalBalance].
@ProviderFor(financeTotalBalance)
final financeTotalBalanceProvider = FutureProvider<double>.internal(
  financeTotalBalance,
  name: r'financeTotalBalanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeTotalBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FinanceTotalBalanceRef = FutureProviderRef<double>;
String _$financeTransactionsForClientHash() =>
    r'5c7078d98ab9c4bfa99887a29dc4e143f657ad3d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [financeTransactionsForClient].
@ProviderFor(financeTransactionsForClient)
const financeTransactionsForClientProvider =
    FinanceTransactionsForClientFamily();

/// See also [financeTransactionsForClient].
class FinanceTransactionsForClientFamily extends Family<List<Transaction>> {
  /// See also [financeTransactionsForClient].
  const FinanceTransactionsForClientFamily();

  /// See also [financeTransactionsForClient].
  FinanceTransactionsForClientProvider call(
    String clientId,
  ) {
    return FinanceTransactionsForClientProvider(
      clientId,
    );
  }

  @override
  FinanceTransactionsForClientProvider getProviderOverride(
    covariant FinanceTransactionsForClientProvider provider,
  ) {
    return call(
      provider.clientId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'financeTransactionsForClientProvider';
}

/// See also [financeTransactionsForClient].
class FinanceTransactionsForClientProvider
    extends AutoDisposeProvider<List<Transaction>> {
  /// See also [financeTransactionsForClient].
  FinanceTransactionsForClientProvider(
    String clientId,
  ) : this._internal(
          (ref) => financeTransactionsForClient(
            ref as FinanceTransactionsForClientRef,
            clientId,
          ),
          from: financeTransactionsForClientProvider,
          name: r'financeTransactionsForClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$financeTransactionsForClientHash,
          dependencies: FinanceTransactionsForClientFamily._dependencies,
          allTransitiveDependencies:
              FinanceTransactionsForClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  FinanceTransactionsForClientProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    List<Transaction> Function(FinanceTransactionsForClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FinanceTransactionsForClientProvider._internal(
        (ref) => create(ref as FinanceTransactionsForClientRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Transaction>> createElement() {
    return _FinanceTransactionsForClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FinanceTransactionsForClientProvider &&
        other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FinanceTransactionsForClientRef
    on AutoDisposeProviderRef<List<Transaction>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _FinanceTransactionsForClientProviderElement
    extends AutoDisposeProviderElement<List<Transaction>>
    with FinanceTransactionsForClientRef {
  _FinanceTransactionsForClientProviderElement(super.provider);

  @override
  String get clientId =>
      (origin as FinanceTransactionsForClientProvider).clientId;
}

String _$financeClientIncomeLtvHash() =>
    r'07f363aaca64726bddcd69a84f4d76f4f83a8a63';

/// See also [financeClientIncomeLtv].
@ProviderFor(financeClientIncomeLtv)
const financeClientIncomeLtvProvider = FinanceClientIncomeLtvFamily();

/// See also [financeClientIncomeLtv].
class FinanceClientIncomeLtvFamily extends Family<double> {
  /// See also [financeClientIncomeLtv].
  const FinanceClientIncomeLtvFamily();

  /// See also [financeClientIncomeLtv].
  FinanceClientIncomeLtvProvider call(
    String clientId,
  ) {
    return FinanceClientIncomeLtvProvider(
      clientId,
    );
  }

  @override
  FinanceClientIncomeLtvProvider getProviderOverride(
    covariant FinanceClientIncomeLtvProvider provider,
  ) {
    return call(
      provider.clientId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'financeClientIncomeLtvProvider';
}

/// See also [financeClientIncomeLtv].
class FinanceClientIncomeLtvProvider extends AutoDisposeProvider<double> {
  /// See also [financeClientIncomeLtv].
  FinanceClientIncomeLtvProvider(
    String clientId,
  ) : this._internal(
          (ref) => financeClientIncomeLtv(
            ref as FinanceClientIncomeLtvRef,
            clientId,
          ),
          from: financeClientIncomeLtvProvider,
          name: r'financeClientIncomeLtvProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$financeClientIncomeLtvHash,
          dependencies: FinanceClientIncomeLtvFamily._dependencies,
          allTransitiveDependencies:
              FinanceClientIncomeLtvFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  FinanceClientIncomeLtvProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    double Function(FinanceClientIncomeLtvRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FinanceClientIncomeLtvProvider._internal(
        (ref) => create(ref as FinanceClientIncomeLtvRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _FinanceClientIncomeLtvProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FinanceClientIncomeLtvProvider &&
        other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FinanceClientIncomeLtvRef on AutoDisposeProviderRef<double> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _FinanceClientIncomeLtvProviderElement
    extends AutoDisposeProviderElement<double> with FinanceClientIncomeLtvRef {
  _FinanceClientIncomeLtvProviderElement(super.provider);

  @override
  String get clientId => (origin as FinanceClientIncomeLtvProvider).clientId;
}

String _$financeTransactionsHash() =>
    r'a97e7d81c6f6742cf58680531f99b3683a05d0e0';

/// See also [FinanceTransactions].
@ProviderFor(FinanceTransactions)
final financeTransactionsProvider =
    AsyncNotifierProvider<FinanceTransactions, List<Transaction>>.internal(
  FinanceTransactions.new,
  name: r'financeTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FinanceTransactions = AsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
