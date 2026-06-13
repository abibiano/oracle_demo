// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppException {

 String get message;
/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppExceptionCopyWith<AppException> get copyWith => _$AppExceptionCopyWithImpl<AppException>(this as AppException, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException(message: $message)';
}


}

/// @nodoc
abstract mixin class $AppExceptionCopyWith<$Res>  {
  factory $AppExceptionCopyWith(AppException value, $Res Function(AppException) _then) = _$AppExceptionCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AppExceptionCopyWithImpl<$Res>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._self, this._then);

  final AppException _self;
  final $Res Function(AppException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppException].
extension AppExceptionPatterns on AppException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthException value)?  auth,TResult Function( ConnectionException value)?  connection,TResult Function( QueryException value)?  query,TResult Function( UnexpectedException value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthException() when auth != null:
return auth(_that);case ConnectionException() when connection != null:
return connection(_that);case QueryException() when query != null:
return query(_that);case UnexpectedException() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthException value)  auth,required TResult Function( ConnectionException value)  connection,required TResult Function( QueryException value)  query,required TResult Function( UnexpectedException value)  unexpected,}){
final _that = this;
switch (_that) {
case AuthException():
return auth(_that);case ConnectionException():
return connection(_that);case QueryException():
return query(_that);case UnexpectedException():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthException value)?  auth,TResult? Function( ConnectionException value)?  connection,TResult? Function( QueryException value)?  query,TResult? Function( UnexpectedException value)?  unexpected,}){
final _that = this;
switch (_that) {
case AuthException() when auth != null:
return auth(_that);case ConnectionException() when connection != null:
return connection(_that);case QueryException() when query != null:
return query(_that);case UnexpectedException() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  auth,TResult Function( String message)?  connection,TResult Function( String message)?  query,TResult Function( String message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthException() when auth != null:
return auth(_that.message);case ConnectionException() when connection != null:
return connection(_that.message);case QueryException() when query != null:
return query(_that.message);case UnexpectedException() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  auth,required TResult Function( String message)  connection,required TResult Function( String message)  query,required TResult Function( String message)  unexpected,}) {final _that = this;
switch (_that) {
case AuthException():
return auth(_that.message);case ConnectionException():
return connection(_that.message);case QueryException():
return query(_that.message);case UnexpectedException():
return unexpected(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  auth,TResult? Function( String message)?  connection,TResult? Function( String message)?  query,TResult? Function( String message)?  unexpected,}) {final _that = this;
switch (_that) {
case AuthException() when auth != null:
return auth(_that.message);case ConnectionException() when connection != null:
return connection(_that.message);case QueryException() when query != null:
return query(_that.message);case UnexpectedException() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AuthException implements AppException {
  const AuthException(this.message);
  

@override final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthExceptionCopyWith<AuthException> get copyWith => _$AuthExceptionCopyWithImpl<AuthException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.auth(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $AuthExceptionCopyWith(AuthException value, $Res Function(AuthException) _then) = _$AuthExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthExceptionCopyWithImpl<$Res>
    implements $AuthExceptionCopyWith<$Res> {
  _$AuthExceptionCopyWithImpl(this._self, this._then);

  final AuthException _self;
  final $Res Function(AuthException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthException(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConnectionException implements AppException {
  const ConnectionException(this.message);
  

@override final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionExceptionCopyWith<ConnectionException> get copyWith => _$ConnectionExceptionCopyWithImpl<ConnectionException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.connection(message: $message)';
}


}

/// @nodoc
abstract mixin class $ConnectionExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $ConnectionExceptionCopyWith(ConnectionException value, $Res Function(ConnectionException) _then) = _$ConnectionExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ConnectionExceptionCopyWithImpl<$Res>
    implements $ConnectionExceptionCopyWith<$Res> {
  _$ConnectionExceptionCopyWithImpl(this._self, this._then);

  final ConnectionException _self;
  final $Res Function(ConnectionException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ConnectionException(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class QueryException implements AppException {
  const QueryException(this.message);
  

@override final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryExceptionCopyWith<QueryException> get copyWith => _$QueryExceptionCopyWithImpl<QueryException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.query(message: $message)';
}


}

/// @nodoc
abstract mixin class $QueryExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $QueryExceptionCopyWith(QueryException value, $Res Function(QueryException) _then) = _$QueryExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$QueryExceptionCopyWithImpl<$Res>
    implements $QueryExceptionCopyWith<$Res> {
  _$QueryExceptionCopyWithImpl(this._self, this._then);

  final QueryException _self;
  final $Res Function(QueryException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(QueryException(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnexpectedException implements AppException {
  const UnexpectedException(this.message);
  

@override final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedExceptionCopyWith<UnexpectedException> get copyWith => _$UnexpectedExceptionCopyWithImpl<UnexpectedException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class $UnexpectedExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $UnexpectedExceptionCopyWith(UnexpectedException value, $Res Function(UnexpectedException) _then) = _$UnexpectedExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$UnexpectedExceptionCopyWithImpl<$Res>
    implements $UnexpectedExceptionCopyWith<$Res> {
  _$UnexpectedExceptionCopyWithImpl(this._self, this._then);

  final UnexpectedException _self;
  final $Res Function(UnexpectedException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UnexpectedException(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
