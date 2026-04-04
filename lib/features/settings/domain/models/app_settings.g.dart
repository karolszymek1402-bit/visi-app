// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      currencyCode: json['currencyCode'] as String? ?? 'PLN',
      locale: json['locale'] as String?,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'currencyCode': instance.currencyCode,
      'locale': instance.locale,
      'hasSeenOnboarding': instance.hasSeenOnboarding,
    };
