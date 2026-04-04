import 'package:hive/hive.dart';
import 'package:visi/features/settings/domain/models/app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  static const hiveTypeId = 5;

  @override
  int get typeId => hiveTypeId;

  @override
  AppSettings read(BinaryReader reader) {
    final currencyCode = reader.readString();
    final locale = reader.readString();
    bool hasSeenOnboarding = false;
    try {
      hasSeenOnboarding = reader.readBool();
    } catch (_) {
      // Backward-compat: starsze wpisy nie zawierają flagi onboardingu.
    }
    return AppSettings(
      currencyCode: currencyCode,
      locale: locale.isEmpty ? null : locale,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.writeString(obj.currencyCode);
    writer.writeString(obj.locale ?? '');
    writer.writeBool(obj.hasSeenOnboarding);
  }
}
