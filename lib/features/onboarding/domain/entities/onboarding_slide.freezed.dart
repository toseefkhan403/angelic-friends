// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_slide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingSlide {

 OnboardingSlideType get slideType; String get title; String get subtitle; String? get imageUrl; String? get eyebrow;
/// Create a copy of OnboardingSlide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingSlideCopyWith<OnboardingSlide> get copyWith => _$OnboardingSlideCopyWithImpl<OnboardingSlide>(this as OnboardingSlide, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingSlide&&(identical(other.slideType, slideType) || other.slideType == slideType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow));
}


@override
int get hashCode => Object.hash(runtimeType,slideType,title,subtitle,imageUrl,eyebrow);

@override
String toString() {
  return 'OnboardingSlide(slideType: $slideType, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, eyebrow: $eyebrow)';
}


}

/// @nodoc
abstract mixin class $OnboardingSlideCopyWith<$Res>  {
  factory $OnboardingSlideCopyWith(OnboardingSlide value, $Res Function(OnboardingSlide) _then) = _$OnboardingSlideCopyWithImpl;
@useResult
$Res call({
 OnboardingSlideType slideType, String title, String subtitle, String? imageUrl, String? eyebrow
});




}
/// @nodoc
class _$OnboardingSlideCopyWithImpl<$Res>
    implements $OnboardingSlideCopyWith<$Res> {
  _$OnboardingSlideCopyWithImpl(this._self, this._then);

  final OnboardingSlide _self;
  final $Res Function(OnboardingSlide) _then;

/// Create a copy of OnboardingSlide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slideType = null,Object? title = null,Object? subtitle = null,Object? imageUrl = freezed,Object? eyebrow = freezed,}) {
  return _then(_self.copyWith(
slideType: null == slideType ? _self.slideType : slideType // ignore: cast_nullable_to_non_nullable
as OnboardingSlideType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,eyebrow: freezed == eyebrow ? _self.eyebrow : eyebrow // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingSlide].
extension OnboardingSlidePatterns on OnboardingSlide {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingSlide value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingSlide() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingSlide value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingSlide():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingSlide value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingSlide() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OnboardingSlideType slideType,  String title,  String subtitle,  String? imageUrl,  String? eyebrow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingSlide() when $default != null:
return $default(_that.slideType,_that.title,_that.subtitle,_that.imageUrl,_that.eyebrow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OnboardingSlideType slideType,  String title,  String subtitle,  String? imageUrl,  String? eyebrow)  $default,) {final _that = this;
switch (_that) {
case _OnboardingSlide():
return $default(_that.slideType,_that.title,_that.subtitle,_that.imageUrl,_that.eyebrow);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OnboardingSlideType slideType,  String title,  String subtitle,  String? imageUrl,  String? eyebrow)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingSlide() when $default != null:
return $default(_that.slideType,_that.title,_that.subtitle,_that.imageUrl,_that.eyebrow);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingSlide implements OnboardingSlide {
  const _OnboardingSlide({required this.slideType, required this.title, required this.subtitle, this.imageUrl, this.eyebrow});
  

@override final  OnboardingSlideType slideType;
@override final  String title;
@override final  String subtitle;
@override final  String? imageUrl;
@override final  String? eyebrow;

/// Create a copy of OnboardingSlide
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingSlideCopyWith<_OnboardingSlide> get copyWith => __$OnboardingSlideCopyWithImpl<_OnboardingSlide>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingSlide&&(identical(other.slideType, slideType) || other.slideType == slideType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.eyebrow, eyebrow) || other.eyebrow == eyebrow));
}


@override
int get hashCode => Object.hash(runtimeType,slideType,title,subtitle,imageUrl,eyebrow);

@override
String toString() {
  return 'OnboardingSlide(slideType: $slideType, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, eyebrow: $eyebrow)';
}


}

/// @nodoc
abstract mixin class _$OnboardingSlideCopyWith<$Res> implements $OnboardingSlideCopyWith<$Res> {
  factory _$OnboardingSlideCopyWith(_OnboardingSlide value, $Res Function(_OnboardingSlide) _then) = __$OnboardingSlideCopyWithImpl;
@override @useResult
$Res call({
 OnboardingSlideType slideType, String title, String subtitle, String? imageUrl, String? eyebrow
});




}
/// @nodoc
class __$OnboardingSlideCopyWithImpl<$Res>
    implements _$OnboardingSlideCopyWith<$Res> {
  __$OnboardingSlideCopyWithImpl(this._self, this._then);

  final _OnboardingSlide _self;
  final $Res Function(_OnboardingSlide) _then;

/// Create a copy of OnboardingSlide
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slideType = null,Object? title = null,Object? subtitle = null,Object? imageUrl = freezed,Object? eyebrow = freezed,}) {
  return _then(_OnboardingSlide(
slideType: null == slideType ? _self.slideType : slideType // ignore: cast_nullable_to_non_nullable
as OnboardingSlideType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,eyebrow: freezed == eyebrow ? _self.eyebrow : eyebrow // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
