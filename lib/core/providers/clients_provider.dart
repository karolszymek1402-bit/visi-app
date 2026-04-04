import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/client.dart';
import '../repositories/client_repository.dart';

part 'clients_provider.g.dart';

// ─── Autorytywny provider klientów ───────────────────────────────────────────

/// `AsyncValue<List<Client>>` — reaktywny, wspierający loading/error UI.
///
/// Używaj [clientsMapProvider] wszędzie, gdzie potrzebujesz szybkiego
/// lookup'u klienta po ID (kalendarze, finanse, itp.).
@riverpod
class Clients extends _$Clients {
  @override
  FutureOr<List<Client>> build() {
    // fetchClients() jest synchroniczny (Hive in-memory) →
    // build() natychmiast zwróci AsyncData bez migotania LoadingState.
    return ref.watch(clientRepositoryProvider).fetchClients();
  }

  /// Dodaj nowego klienta lub nadpisz istniejący.
  Future<void> addOrUpdateClient(Client client) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientRepositoryProvider).saveClient(client);
      return ref.read(clientRepositoryProvider).fetchClients();
    });
  }

  /// Usuń klienta i wszystkie jego wizyty.
  Future<void> removeClient(String id) async {
    final previous = state.valueOrNull ?? ref.read(clientRepositoryProvider).fetchClients();
    final next = previous.where((client) => client.id != id).toList(growable: false);

    // Optimistic update: UI odświeża się natychmiast bez pełnego refetch.
    state = AsyncData(next);

    try {
      await ref.read(clientRepositoryProvider).deleteClient(id);
    } catch (error, stackTrace) {
      // Rollback stanu przy błędzie i przekazanie wyjątku do warstwy UI.
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Backward-compatible alias.
  Future<void> deleteClient(String id) async {
    await removeClient(id);
  }
}

// ─── Derived provider — mapa do szybkiego lookup po ID ───────────────────────

/// `Map<String, Client>` — synchroniczny lookup klienta po ID.
///
/// Używaj tego w providerach kalendarza, finansów i widgetach,
/// które potrzebują `clients[visit.clientId]`.
/// Automatycznie się odświeża gdy [clientsProvider] zmieni stan.
final clientsMapProvider = Provider<Map<String, Client>>((ref) {
  final list = ref.watch(clientsProvider).valueOrNull ?? const [];
  return {for (final c in list) c.id: c};
});
