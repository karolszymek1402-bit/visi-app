import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Model danych dla precyzyjnego nachylenia
class TiltData {
  final double x;
  final double y;
  TiltData(this.x, this.y);
}

/// Provider strumieniujący dane z akcelerometru przetworzone pod Rive
final tiltProvider = StreamProvider<TiltData>((ref) {
  return accelerometerEventStream().map((event) {
    // Akcelerometr zwraca ~ -10 do 10 m/s^2.
    // Mapujemy na zakres -1.0 do 1.0 dla osi Rive.
    double x = (event.x / 8.0).clamp(-1.0, 1.0);
    double y = (event.y / 8.0).clamp(-1.0, 1.0);

    return TiltData(x, y);
  });
});
