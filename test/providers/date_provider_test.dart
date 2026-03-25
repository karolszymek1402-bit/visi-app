import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/providers/date_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SelectedDateController', () {
    test('should start with today', () {
      final date = container.read(selectedDateProvider);
      final now = DateTime.now();

      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
      // Powinien być znormalizowany (bez godzin)
      expect(date.hour, 0);
      expect(date.minute, 0);
    });

    test('setDate should change selected date', () {
      final target = DateTime(2026, 6, 15);
      container.read(selectedDateProvider.notifier).setDate(target);

      final date = container.read(selectedDateProvider);
      expect(date, DateTime(2026, 6, 15));
    });

    test('nextDay should advance by one day', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20));
      container.read(selectedDateProvider.notifier).nextDay();

      expect(container.read(selectedDateProvider), DateTime(2026, 3, 21));
    });

    test('previousDay should go back one day', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20));
      container.read(selectedDateProvider.notifier).previousDay();

      expect(container.read(selectedDateProvider), DateTime(2026, 3, 19));
    });

    test('today should reset to current date', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2025, 1, 1));
      container.read(selectedDateProvider.notifier).today();

      final date = container.read(selectedDateProvider);
      final now = DateTime.now();
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('setDate should normalize time to midnight', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20, 14, 30, 45));

      final date = container.read(selectedDateProvider);
      expect(date.hour, 0);
      expect(date.minute, 0);
      expect(date.second, 0);
    });
  });
}
