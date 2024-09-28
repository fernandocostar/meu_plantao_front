// Mocks generated by Mockito 5.4.4 from annotations
// in meu_plantao_front/test/service/auth_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:meu_plantao_front/service/auth_service.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i2.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get apiUrl => (super.noSuchMethod(
        Invocation.getter(#apiUrl),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#apiUrl),
        ),
      ) as String);

  @override
  void Function(String) get showErrorDialog => (super.noSuchMethod(
        Invocation.getter(#showErrorDialog),
        returnValue: (String __p0) {},
      ) as void Function(String));

  @override
  void Function(Map<String, dynamic>) get navigateToHomePage =>
      (super.noSuchMethod(
        Invocation.getter(#navigateToHomePage),
        returnValue: (Map<String, dynamic> __p0) {},
      ) as void Function(Map<String, dynamic>));

  @override
  _i4.Future<void> signUserIn(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUserIn,
          [
            email,
            password,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> signUpUser(
    String? email,
    String? password,
    String? name,
    int? professionalType,
    String? professionalRegister,
    String? state,
    String? city,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUpUser,
          [
            email,
            password,
            name,
            professionalType,
            professionalRegister,
            state,
            city,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> storeToken(String? token) => (super.noSuchMethod(
        Invocation.method(
          #storeToken,
          [token],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> storeUserName(String? userName) => (super.noSuchMethod(
        Invocation.method(
          #storeUserName,
          [userName],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> storeEmail(String? email) => (super.noSuchMethod(
        Invocation.method(
          #storeEmail,
          [email],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> removeToken() => (super.noSuchMethod(
        Invocation.method(
          #removeToken,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
