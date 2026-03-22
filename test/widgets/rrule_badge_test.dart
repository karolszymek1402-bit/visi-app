import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/clients/presentation/widgets/rrule_badge.dart';

void main() {
  group('RRuleBadge.humanizeRRule', () {
    test('weekly single day', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;BYDAY=MO'),
        'Co tydzień: Pn',
      );
    });

    test('weekly multiple days', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;BYDAY=MO,WE,FR'),
        'Co tydzień: Pn, Śr, Pt',
      );
    });

    test('weekly all days', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU'),
        'Co tydzień: Pn, Wt, Śr, Cz, Pt, So, Nd',
      );
    });

    test('bi-weekly', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH'),
        'Co 2 tyg.: Wt, Cz',
      );
    });

    test('tri-weekly', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;INTERVAL=3;BYDAY=MO'),
        'Co 3 tyg.: Pn',
      );
    });

    test('daily', () {
      expect(RRuleBadge.humanizeRRule('FREQ=DAILY'), 'Codziennie');
    });

    test('daily with interval 1', () {
      expect(RRuleBadge.humanizeRRule('FREQ=DAILY;INTERVAL=1'), 'Codziennie');
    });

    test('every 3 days', () {
      expect(RRuleBadge.humanizeRRule('FREQ=DAILY;INTERVAL=3'), 'Co 3 dni');
    });

    test('unknown frequency returns raw rrule', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=MONTHLY;BYDAY=1MO'),
        'FREQ=MONTHLY;BYDAY=1MO',
      );
    });

    test('weekend days translated correctly', () {
      expect(
        RRuleBadge.humanizeRRule('FREQ=WEEKLY;BYDAY=SA,SU'),
        'Co tydzień: So, Nd',
      );
    });
  });
}
