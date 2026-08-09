// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_slide_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingSlideModel {

 String get title; String get subtitle;@JsonKey(name: 'image_url') String get imageUrl;
/// Create a copy of OnboardingSlideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingSlideModelCopyWith<OnboardingSlideModel> get copyWith => _$OnboardingSlideModelCopyWithImpl<OnboardingSlideModel>(this as OnboardingSlideModel, _$identity);

  /// Serializes this OnboardingSlideModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingSlideModel&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,imageUrl);

@override
String toString() {
  return 'OnboardingSlideModel(title: $title, subtitle: $subtitle, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $OnboardingSlideModelCopyWith<$Res>  {
  factory $OnboardingSlideModelCopyWith(OnboardingSlideModel value, $Res Function(OnboardingSlideModel) _then) = _$OnboardingSlideModelCopyWithImpl;
@useResult
$Res call({
 String title, String subtitle,@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class _$OnboardingSlideModelCopyWithImpl<$Res>
    implements $OnboardingSlideModelCopyWith<$Res> {
  _$OnboardingSlideModelCopyWithImpl(this._self, this._then);

  final OnboardingSlideModel _self;
  final $Res Function(OnboardingSlideModel) _then;

/// Create a copy of OnboardingSlideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? subtitle = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingSlideModel].
extension OnboardingSlideModelPatterns on OnboardingSlideModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingSlideModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingSlideModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingSlideModel value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingSlideModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingSlideModel value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingSlideModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String subtitle, @JsonKey(name: 'image_url')  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingSlideModel() when $default != null:
return $default(_that.title,_that.subtitle,_that.imageUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String subtitle, @JsonKey(name: 'image_url')  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _OnboardingSlideModel():
return $default(_that.title,_that.subtitle,_that.imageUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String subtitle, @JsonKey(name: 'image_url')  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingSlideModel() when $default != null:
return $default(_that.title,_that.subtitle,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingSlideModel extends OnboardingSlideModel {
  const _OnboardingSlideModel({required this.title, required this.subtitle, @JsonKey(name: 'image_url') required this.imageUrl}): super._();
  factory _OnboardingSlideModel.fromJson(Map<String, dynamic> json) => _$OnboardingSlideModelFromJson(json);

@override final  String title;
@override final  String subtitle;
@override@JsonKey(name: 'image_url') final  String imageUrl;

/// Create a copy of OnboardingSlideModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingSlideModelCopyWith<_OnboardingSlideModel> get copyWith => __$OnboardingSlideModelCopyWithImpl<_OnboardingSlideModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingSlideModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingSlideModel&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,imageUrl);

@override
String toString() {
  return 'OnboardingSlideModel(title: $title, subtitle: $subtitle, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$OnboardingSlideModelCopyWith<$Res> implements $OnboardingSlideModelCopyWith<$Res> {
  factory _$OnboardingSlideModelCopyWith(_OnboardingSlideModel value, $Res Function(_OnboardingSlideModel) _then) = __$OnboardingSlideModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String subtitle,@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class __$OnboardingSlideModelCopyWithImpl<$Res>
    implements _$OnboardingSlideModelCopyWith<$Res> {
  __$OnboardingSlideModelCopyWithImpl(this._self, this._then);

  final _OnboardingSlideModel _self;
  final $Res Function(_OnboardingSlideModel) _then;

/// Create a copy of OnboardingSlideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? subtitle = null,Object? imageUrl = null,}) {
  return _then(_OnboardingSlideModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
