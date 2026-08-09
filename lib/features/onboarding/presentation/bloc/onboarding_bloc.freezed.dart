// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnboardingEvent()';
}


}

/// @nodoc
class $OnboardingEventCopyWith<$Res>  {
$OnboardingEventCopyWith(OnboardingEvent _, $Res Function(OnboardingEvent) __);
}


/// Adds pattern-matching-related methods to [OnboardingEvent].
extension OnboardingEventPatterns on OnboardingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnboardingStarted value)?  started,TResult Function( OnboardingNameChanged value)?  nameChanged,TResult Function( OnboardingSubmitted value)?  submitted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnboardingStarted() when started != null:
return started(_that);case OnboardingNameChanged() when nameChanged != null:
return nameChanged(_that);case OnboardingSubmitted() when submitted != null:
return submitted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnboardingStarted value)  started,required TResult Function( OnboardingNameChanged value)  nameChanged,required TResult Function( OnboardingSubmitted value)  submitted,}){
final _that = this;
switch (_that) {
case OnboardingStarted():
return started(_that);case OnboardingNameChanged():
return nameChanged(_that);case OnboardingSubmitted():
return submitted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnboardingStarted value)?  started,TResult? Function( OnboardingNameChanged value)?  nameChanged,TResult? Function( OnboardingSubmitted value)?  submitted,}){
final _that = this;
switch (_that) {
case OnboardingStarted() when started != null:
return started(_that);case OnboardingNameChanged() when nameChanged != null:
return nameChanged(_that);case OnboardingSubmitted() when submitted != null:
return submitted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String name)?  nameChanged,TResult Function()?  submitted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnboardingStarted() when started != null:
return started();case OnboardingNameChanged() when nameChanged != null:
return nameChanged(_that.name);case OnboardingSubmitted() when submitted != null:
return submitted();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String name)  nameChanged,required TResult Function()  submitted,}) {final _that = this;
switch (_that) {
case OnboardingStarted():
return started();case OnboardingNameChanged():
return nameChanged(_that.name);case OnboardingSubmitted():
return submitted();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String name)?  nameChanged,TResult? Function()?  submitted,}) {final _that = this;
switch (_that) {
case OnboardingStarted() when started != null:
return started();case OnboardingNameChanged() when nameChanged != null:
return nameChanged(_that.name);case OnboardingSubmitted() when submitted != null:
return submitted();case _:
  return null;

}
}

}

/// @nodoc


class OnboardingStarted implements OnboardingEvent {
  const OnboardingStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnboardingEvent.started()';
}


}




/// @nodoc


class OnboardingNameChanged implements OnboardingEvent {
  const OnboardingNameChanged(this.name);
  

 final  String name;

/// Create a copy of OnboardingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingNameChangedCopyWith<OnboardingNameChanged> get copyWith => _$OnboardingNameChangedCopyWithImpl<OnboardingNameChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingNameChanged&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'OnboardingEvent.nameChanged(name: $name)';
}


}

/// @nodoc
abstract mixin class $OnboardingNameChangedCopyWith<$Res> implements $OnboardingEventCopyWith<$Res> {
  factory $OnboardingNameChangedCopyWith(OnboardingNameChanged value, $Res Function(OnboardingNameChanged) _then) = _$OnboardingNameChangedCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$OnboardingNameChangedCopyWithImpl<$Res>
    implements $OnboardingNameChangedCopyWith<$Res> {
  _$OnboardingNameChangedCopyWithImpl(this._self, this._then);

  final OnboardingNameChanged _self;
  final $Res Function(OnboardingNameChanged) _then;

/// Create a copy of OnboardingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(OnboardingNameChanged(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class OnboardingSubmitted implements OnboardingEvent {
  const OnboardingSubmitted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingSubmitted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnboardingEvent.submitted()';
}


}




/// @nodoc
mixin _$OnboardingState {

 OnboardingSlidesStatus get slidesStatus; List<OnboardingSlide> get slides; String? get slidesErrorMessage; String get name; NameSubmitStatus get submitStatus; String? get submitErrorMessage;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.slidesStatus, slidesStatus) || other.slidesStatus == slidesStatus)&&const DeepCollectionEquality().equals(other.slides, slides)&&(identical(other.slidesErrorMessage, slidesErrorMessage) || other.slidesErrorMessage == slidesErrorMessage)&&(identical(other.name, name) || other.name == name)&&(identical(other.submitStatus, submitStatus) || other.submitStatus == submitStatus)&&(identical(other.submitErrorMessage, submitErrorMessage) || other.submitErrorMessage == submitErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,slidesStatus,const DeepCollectionEquality().hash(slides),slidesErrorMessage,name,submitStatus,submitErrorMessage);

@override
String toString() {
  return 'OnboardingState(slidesStatus: $slidesStatus, slides: $slides, slidesErrorMessage: $slidesErrorMessage, name: $name, submitStatus: $submitStatus, submitErrorMessage: $submitErrorMessage)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 OnboardingSlidesStatus slidesStatus, List<OnboardingSlide> slides, String? slidesErrorMessage, String name, NameSubmitStatus submitStatus, String? submitErrorMessage
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slidesStatus = null,Object? slides = null,Object? slidesErrorMessage = freezed,Object? name = null,Object? submitStatus = null,Object? submitErrorMessage = freezed,}) {
  return _then(_self.copyWith(
slidesStatus: null == slidesStatus ? _self.slidesStatus : slidesStatus // ignore: cast_nullable_to_non_nullable
as OnboardingSlidesStatus,slides: null == slides ? _self.slides : slides // ignore: cast_nullable_to_non_nullable
as List<OnboardingSlide>,slidesErrorMessage: freezed == slidesErrorMessage ? _self.slidesErrorMessage : slidesErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,submitStatus: null == submitStatus ? _self.submitStatus : submitStatus // ignore: cast_nullable_to_non_nullable
as NameSubmitStatus,submitErrorMessage: freezed == submitErrorMessage ? _self.submitErrorMessage : submitErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OnboardingSlidesStatus slidesStatus,  List<OnboardingSlide> slides,  String? slidesErrorMessage,  String name,  NameSubmitStatus submitStatus,  String? submitErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.slidesStatus,_that.slides,_that.slidesErrorMessage,_that.name,_that.submitStatus,_that.submitErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OnboardingSlidesStatus slidesStatus,  List<OnboardingSlide> slides,  String? slidesErrorMessage,  String name,  NameSubmitStatus submitStatus,  String? submitErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.slidesStatus,_that.slides,_that.slidesErrorMessage,_that.name,_that.submitStatus,_that.submitErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OnboardingSlidesStatus slidesStatus,  List<OnboardingSlide> slides,  String? slidesErrorMessage,  String name,  NameSubmitStatus submitStatus,  String? submitErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.slidesStatus,_that.slides,_that.slidesErrorMessage,_that.name,_that.submitStatus,_that.submitErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState implements OnboardingState {
  const _OnboardingState({this.slidesStatus = OnboardingSlidesStatus.loading, final  List<OnboardingSlide> slides = const <OnboardingSlide>[], this.slidesErrorMessage, this.name = '', this.submitStatus = NameSubmitStatus.initial, this.submitErrorMessage}): _slides = slides;
  

@override@JsonKey() final  OnboardingSlidesStatus slidesStatus;
 final  List<OnboardingSlide> _slides;
@override@JsonKey() List<OnboardingSlide> get slides {
  if (_slides is EqualUnmodifiableListView) return _slides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slides);
}

@override final  String? slidesErrorMessage;
@override@JsonKey() final  String name;
@override@JsonKey() final  NameSubmitStatus submitStatus;
@override final  String? submitErrorMessage;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.slidesStatus, slidesStatus) || other.slidesStatus == slidesStatus)&&const DeepCollectionEquality().equals(other._slides, _slides)&&(identical(other.slidesErrorMessage, slidesErrorMessage) || other.slidesErrorMessage == slidesErrorMessage)&&(identical(other.name, name) || other.name == name)&&(identical(other.submitStatus, submitStatus) || other.submitStatus == submitStatus)&&(identical(other.submitErrorMessage, submitErrorMessage) || other.submitErrorMessage == submitErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,slidesStatus,const DeepCollectionEquality().hash(_slides),slidesErrorMessage,name,submitStatus,submitErrorMessage);

@override
String toString() {
  return 'OnboardingState(slidesStatus: $slidesStatus, slides: $slides, slidesErrorMessage: $slidesErrorMessage, name: $name, submitStatus: $submitStatus, submitErrorMessage: $submitErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 OnboardingSlidesStatus slidesStatus, List<OnboardingSlide> slides, String? slidesErrorMessage, String name, NameSubmitStatus submitStatus, String? submitErrorMessage
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slidesStatus = null,Object? slides = null,Object? slidesErrorMessage = freezed,Object? name = null,Object? submitStatus = null,Object? submitErrorMessage = freezed,}) {
  return _then(_OnboardingState(
slidesStatus: null == slidesStatus ? _self.slidesStatus : slidesStatus // ignore: cast_nullable_to_non_nullable
as OnboardingSlidesStatus,slides: null == slides ? _self._slides : slides // ignore: cast_nullable_to_non_nullable
as List<OnboardingSlide>,slidesErrorMessage: freezed == slidesErrorMessage ? _self.slidesErrorMessage : slidesErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,submitStatus: null == submitStatus ? _self.submitStatus : submitStatus // ignore: cast_nullable_to_non_nullable
as NameSubmitStatus,submitErrorMessage: freezed == submitErrorMessage ? _self.submitErrorMessage : submitErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
