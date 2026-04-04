import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/calendar/presentation/widgets/complete_visit_sheet.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/finance/presentation/widgets/add_transaction_sheet.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

class _FakeFinanceRepository extends FinanceRepository {
  _FakeFinanceRepository({List<Transaction>? seed})
    : _items = List<Transaction>.from(seed ?? const []);

  final List<Transaction> _items;
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  @override
  Future<List<Transaction>> getTransactions() async {
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    yield await getTransactions();
    yield* _controller.stream;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _items.add(transaction);
    _controller.add(await getTransactions());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
    _controller.add(await getTransactions());
  }

  @override
  Future<double> getTotalBalance() async {
    return _items.fold<double>(0, (sum, t) => sum + t.signedAmount);
  }
}

class _OpenCompleteVisitSheetHost extends StatefulWidget {
  const _OpenCompleteVisitSheetHost({
    required this.visit,
    required this.client,
  });

  final Visit visit;
  final Client client;

  @override
  State<_OpenCompleteVisitSheetHost> createState() =>
      _OpenCompleteVisitSheetHostState();
}

class _OpenCompleteVisitSheetHostState extends State<_OpenCompleteVisitSheetHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CompleteVisitSheet(
          visit: widget.visit,
          client: widget.client,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;
  late _FakeFinanceRepository fakeFinanceRepository;
  late Visit visit;
  late Client client;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();

    final now = DateTime.now();
    client = const Client(
      id: 'c1',
      name: 'Oslo Klinikk',
      customRate: 250,
      colorValue: 0xFF2F58CD,
    );
    visit = Visit(
      id: 'v1',
      clientId: client.id,
      scheduledStart: DateTime(now.year, now.month, now.day, 8, 0),
      scheduledEnd: DateTime(now.year, now.month, now.day, 10, 0),
      status: VisitStatus.scheduled,
    );

    fakeDb.seedTestData(
      clients: {client.id: client},
      visits: [visit],
    );
    fakeFinanceRepository = _FakeFinanceRepository();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
        financeRepositoryProvider.overrideWith((ref) => fakeFinanceRepository),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _OpenCompleteVisitSheetHost(visit: visit, client: client),
      ),
    );
  }

  testWidgets('Scenariusz A: nowe rozliczenie otwiera AddTransactionSheet z prefill', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(CompleteVisitSheet), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Zapisz'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionSheet), findsOneWidget);

    final amountField = tester.widget<TextFormField>(find.byType(TextFormField).at(0));
    final categoryField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );

    expect(amountField.controller?.text, '500.00');
    expect(categoryField.controller?.text, 'Oslo Klinikk');
  });

  testWidgets('Scenariusz B: guard blokuje duplikat i pokazuje status powiązania', (
    tester,
  ) async {
    fakeFinanceRepository = _FakeFinanceRepository(
      seed: [
        Transaction(
          id: 'tx_existing',
          amount: 500,
          date: visit.scheduledEnd,
          type: TransactionType.income,
          category: client.name,
          clientId: client.id,
          visitId: visit.id,
        ),
      ],
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final labelFinder = find.text('Powiązane z wizytą');
    expect(labelFinder, findsOneWidget);

    final linkedButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Powiązane z wizytą'),
    );
    expect(linkedButton.onPressed, isNull);
  });
}
