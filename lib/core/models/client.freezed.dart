// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Client {
  String get id => throw _privateConstructorUsedError;
  String get name =>
      throw _privateConstructorUsedError; // ── Kontakt ──────────────────────────────────────────────────────────────
  String? get phone => throw _privateConstructorUsedError;
  String? get email =>
      throw _privateConstructorUsedError; // ── Stawka ───────────────────────────────────────────────────────────────
  /// Stawka specyficzna dla klienta. `null` → używaj stawki profilu.
  double? get customRate =>
      throw _privateConstructorUsedError; // ── Wizytówka / Prezentacja ──────────────────────────────────────────────
  String? get address => throw _privateConstructorUsedError;

  /// Kolor jako int (Color.value). Napędza kolorowe kafelki klienta.
  int? get colorValue =>
      throw _privateConstructorUsedError; // ── Cykl wizyt (RRule) ───────────────────────────────────────────────────
  String? get recurrencePattern => throw _privateConstructorUsedError;
  int get defaultStartHour => throw _privateConstructorUsedError;
  int get defaultStartMinute => throw _privateConstructorUsedError;
  int get defaultDurationMinutes =>
      throw _privateConstructorUsedError; // ── Komunikacja ──────────────────────────────────────────────────────────
  String? get smsTemplate =>
      throw _privateConstructorUsedError; // ── Notatka ──────────────────────────────────────────────────────────────
  String? get notes =>
      throw _privateConstructorUsedError; // ── Powiązane wizyty ─────────────────────────────────────────────────────
  List<String> get visitIds =>
      throw _privateConstructorUsedError; // ── Metadane ─────────────────────────────────────────────────────────────
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? email,
      double? customRate,
      String? address,
      int? colorValue,
      String? recurrencePattern,
      int defaultStartHour,
      int defaultStartMinute,
      int defaultDurationMinutes,
      String? smsTemplate,
      String? notes,
      List<String> visitIds,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? customRate = freezed,
    Object? address = freezed,
    Object? colorValue = freezed,
    Object? recurrencePattern = freezed,
    Object? defaultStartHour = null,
    Object? defaultStartMinute = null,
    Object? defaultDurationMinutes = null,
    Object? smsTemplate = freezed,
    Object? notes = freezed,
    Object? visitIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      customRate: freezed == customRate
          ? _value.customRate
          : customRate // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultStartHour: null == defaultStartHour
          ? _value.defaultStartHour
          : defaultStartHour // ignore: cast_nullable_to_non_nullable
              as int,
      defaultStartMinute: null == defaultStartMinute
          ? _value.defaultStartMinute
          : defaultStartMinute // ignore: cast_nullable_to_non_nullable
              as int,
      defaultDurationMinutes: null == defaultDurationMinutes
          ? _value.defaultDurationMinutes
          : defaultDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      smsTemplate: freezed == smsTemplate
          ? _value.smsTemplate
          : smsTemplate // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      visitIds: null == visitIds
          ? _value.visitIds
          : visitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientImplCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$ClientImplCopyWith(
          _$ClientImpl value, $Res Function(_$ClientImpl) then) =
      __$$ClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? email,
      double? customRate,
      String? address,
      int? colorValue,
      String? recurrencePattern,
      int defaultStartHour,
      int defaultStartMinute,
      int defaultDurationMinutes,
      String? smsTemplate,
      String? notes,
      List<String> visitIds,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ClientImplCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$ClientImpl>
    implements _$$ClientImplCopyWith<$Res> {
  __$$ClientImplCopyWithImpl(
      _$ClientImpl _value, $Res Function(_$ClientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? customRate = freezed,
    Object? address = freezed,
    Object? colorValue = freezed,
    Object? recurrencePattern = freezed,
    Object? defaultStartHour = null,
    Object? defaultStartMinute = null,
    Object? defaultDurationMinutes = null,
    Object? smsTemplate = freezed,
    Object? notes = freezed,
    Object? visitIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ClientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      customRate: freezed == customRate
          ? _value.customRate
          : customRate // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultStartHour: null == defaultStartHour
          ? _value.defaultStartHour
          : defaultStartHour // ignore: cast_nullable_to_non_nullable
              as int,
      defaultStartMinute: null == defaultStartMinute
          ? _value.defaultStartMinute
          : defaultStartMinute // ignore: cast_nullable_to_non_nullable
              as int,
      defaultDurationMinutes: null == defaultDurationMinutes
          ? _value.defaultDurationMinutes
          : defaultDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      smsTemplate: freezed == smsTemplate
          ? _value.smsTemplate
          : smsTemplate // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      visitIds: null == visitIds
          ? _value._visitIds
          : visitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$ClientImpl extends _Client {
  const _$ClientImpl(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.customRate,
      this.address,
      this.colorValue,
      this.recurrencePattern,
      this.defaultStartHour = 8,
      this.defaultStartMinute = 0,
      this.defaultDurationMinutes = 120,
      this.smsTemplate,
      this.notes,
      final List<String> visitIds = const [],
      this.createdAt,
      this.updatedAt})
      : _visitIds = visitIds,
        super._();

  @override
  final String id;
  @override
  final String name;
// ── Kontakt ──────────────────────────────────────────────────────────────
  @override
  final String? phone;
  @override
  final String? email;
// ── Stawka ───────────────────────────────────────────────────────────────
  /// Stawka specyficzna dla klienta. `null` → używaj stawki profilu.
  @override
  final double? customRate;
// ── Wizytówka / Prezentacja ──────────────────────────────────────────────
  @override
  final String? address;

  /// Kolor jako int (Color.value). Napędza kolorowe kafelki klienta.
  @override
  final int? colorValue;
// ── Cykl wizyt (RRule) ───────────────────────────────────────────────────
  @override
  final String? recurrencePattern;
  @override
  @JsonKey()
  final int defaultStartHour;
  @override
  @JsonKey()
  final int defaultStartMinute;
  @override
  @JsonKey()
  final int defaultDurationMinutes;
// ── Komunikacja ──────────────────────────────────────────────────────────
  @override
  final String? smsTemplate;
// ── Notatka ──────────────────────────────────────────────────────────────
  @override
  final String? notes;
// ── Powiązane wizyty ─────────────────────────────────────────────────────
  final List<String> _visitIds;
// ── Powiązane wizyty ─────────────────────────────────────────────────────
  @override
  @JsonKey()
  List<String> get visitIds {
    if (_visitIds is EqualUnmodifiableListView) return _visitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visitIds);
  }

// ── Metadane ─────────────────────────────────────────────────────────────
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Client(id: $id, name: $name, phone: $phone, email: $email, customRate: $customRate, address: $address, colorValue: $colorValue, recurrencePattern: $recurrencePattern, defaultStartHour: $defaultStartHour, defaultStartMinute: $defaultStartMinute, defaultDurationMinutes: $defaultDurationMinutes, smsTemplate: $smsTemplate, notes: $notes, visitIds: $visitIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.customRate, customRate) ||
                other.customRate == customRate) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.recurrencePattern, recurrencePattern) ||
                other.recurrencePattern == recurrencePattern) &&
            (identical(other.defaultStartHour, defaultStartHour) ||
                other.defaultStartHour == defaultStartHour) &&
            (identical(other.defaultStartMinute, defaultStartMinute) ||
                other.defaultStartMinute == defaultStartMinute) &&
            (identical(other.defaultDurationMinutes, defaultDurationMinutes) ||
                other.defaultDurationMinutes == defaultDurationMinutes) &&
            (identical(other.smsTemplate, smsTemplate) ||
                other.smsTemplate == smsTemplate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._visitIds, _visitIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      phone,
      email,
      customRate,
      address,
      colorValue,
      recurrencePattern,
      defaultStartHour,
      defaultStartMinute,
      defaultDurationMinutes,
      smsTemplate,
      notes,
      const DeepCollectionEquality().hash(_visitIds),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      __$$ClientImplCopyWithImpl<_$ClientImpl>(this, _$identity);
}

abstract class _Client extends Client {
  const factory _Client(
      {required final String id,
      required final String name,
      final String? phone,
      final String? email,
      final double? customRate,
      final String? address,
      final int? colorValue,
      final String? recurrencePattern,
      final int defaultStartHour,
      final int defaultStartMinute,
      final int defaultDurationMinutes,
      final String? smsTemplate,
      final String? notes,
      final List<String> visitIds,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ClientImpl;
  const _Client._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override // ── Kontakt ──────────────────────────────────────────────────────────────
  String? get phone;
  @override
  String? get email;
  @override // ── Stawka ───────────────────────────────────────────────────────────────
  /// Stawka specyficzna dla klienta. `null` → używaj stawki profilu.
  double? get customRate;
  @override // ── Wizytówka / Prezentacja ──────────────────────────────────────────────
  String? get address;
  @override

  /// Kolor jako int (Color.value). Napędza kolorowe kafelki klienta.
  int? get colorValue;
  @override // ── Cykl wizyt (RRule) ───────────────────────────────────────────────────
  String? get recurrencePattern;
  @override
  int get defaultStartHour;
  @override
  int get defaultStartMinute;
  @override
  int get defaultDurationMinutes;
  @override // ── Komunikacja ──────────────────────────────────────────────────────────
  String? get smsTemplate;
  @override // ── Notatka ──────────────────────────────────────────────────────────────
  String? get notes;
  @override // ── Powiązane wizyty ─────────────────────────────────────────────────────
  List<String> get visitIds;
  @override // ── Metadane ─────────────────────────────────────────────────────────────
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
