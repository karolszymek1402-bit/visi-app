// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$languageSelectedHash() => r'42d3a7b5270572ce0ad9b77c6332ed0ab3dc933b';

/// Czy użytkownik przeszedł ekran wyboru języka?
///
/// Copied from [LanguageSelected].
@ProviderFor(LanguageSelected)
final languageSelectedProvider =
    NotifierProvider<LanguageSelected, bool>.internal(
  LanguageSelected.new,
  name: r'languageSelectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$languageSelectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LanguageSelected = Notifier<bool>;
String _$localeControllerHash() => r'89b30fece00f73ddb2e6698ebc8363b270a82ff4';

/// See also [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    AutoDisposeNotifierProvider<LocaleController, Locale>.internal(
  LocaleController.new,
  name: r'localeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleController = AutoDisposeNotifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
