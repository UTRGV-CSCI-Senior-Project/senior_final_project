// Mocks generated by Mockito 5.4.4 from annotations
// in folio/test/unit/services/service_locator_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:folio/services/gemini_services.dart' as _i2;
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

/// A class which mocks [GeminiServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeminiServices extends _i1.Mock implements _i2.GeminiServices {
  MockGeminiServices() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get modelId => (super.noSuchMethod(
        Invocation.getter(#modelId),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#modelId),
        ),
      ) as String);

  @override
  _i4.Future<List<String>> aiSearch(String? promptUser) => (super.noSuchMethod(
        Invocation.method(
          #aiSearch,
          [promptUser],
        ),
        returnValue: _i4.Future<List<String>>.value(<String>[]),
      ) as _i4.Future<List<String>>);

  @override
  _i4.Future<List<String>> aiEvaluator(String? userPrompt) =>
      (super.noSuchMethod(
        Invocation.method(
          #aiEvaluator,
          [userPrompt],
        ),
        returnValue: _i4.Future<List<String>>.value(<String>[]),
      ) as _i4.Future<List<String>>);

  @override
  _i4.Future<List<String>> aiDiscover(String? promptUser) =>
      (super.noSuchMethod(
        Invocation.method(
          #aiDiscover,
          [promptUser],
        ),
        returnValue: _i4.Future<List<String>>.value(<String>[]),
      ) as _i4.Future<List<String>>);
}
