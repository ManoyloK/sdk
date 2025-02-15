// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/ast/token.dart';
import 'package:analyzer/src/dart/error/lint_codes.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:test/test.dart';

import '../../generated/test_support.dart';

main() {
  group('lint rule', () {
    group('code creation', () {
      test('without published diagnostic docs', () {
        expect(customCode.url,
            equals('https://dart.dev/lints/${customCode.name}'));
      });

      test('with published diagnostic docs', () {
        expect(customCodeWithDocs.url,
            equals('https://dart.dev/diagnostics/${customCodeWithDocs.name}'));
      });
    });

    group('error code reporting', () {
      test('reportLintForToken (custom)', () {
        var rule = TestRule();
        var reporter =
            CollectingReporter(GatheringErrorListener(), _MockSource('mock'));
        rule.reporter = reporter;

        rule.reportLintForToken(Token.eof(0),
            errorCode: customCode, ignoreSyntheticTokens: false);
        expect(reporter.code, customCode);
      });
      test('reportLintForToken (default)', () {
        var rule = TestRule();
        var reporter =
            CollectingReporter(GatheringErrorListener(), _MockSource('mock'));
        rule.reporter = reporter;

        rule.reportLintForToken(Token.eof(0), ignoreSyntheticTokens: false);
        expect(reporter.code, rule.lintCode);
      });
      test('reportLint (custom)', () {
        var rule = TestRule();
        var reporter =
            CollectingReporter(GatheringErrorListener(), _MockSource('mock'));
        rule.reporter = reporter;

        var node = EmptyStatementImpl(
          semicolon: SimpleToken(TokenType.SEMICOLON, 0),
        );
        rule.reportLint(node, errorCode: customCode);
        expect(reporter.code, customCode);
      });
      test('reportLint (default)', () {
        var rule = TestRule();
        var reporter =
            CollectingReporter(GatheringErrorListener(), _MockSource('mock'));
        rule.reporter = reporter;

        var node = EmptyStatementImpl(
          semicolon: SimpleToken(TokenType.SEMICOLON, 0),
        );
        rule.reportLint(node);
        expect(reporter.code, rule.lintCode);
      });
    });
  });
}

const LintCode customCode = LintCode(
    'hash_and_equals', 'Override `==` if overriding `hashCode`.',
    correctionMessage: 'Implement `==`.');

const LintCode customCodeWithDocs = LintCode(
    'hash_and_equals', 'Override `==` if overriding `hashCode`.',
    correctionMessage: 'Implement `==`.', hasPublishedDocs: true);

class CollectingReporter extends ErrorReporter {
  ErrorCode? code;

  CollectingReporter(super.listener, super.source);

  @override
  void atElement(
    Element element,
    ErrorCode errorCode, {
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
    Object? data,
  }) {
    code = errorCode;
  }

  @override
  void atNode(
    AstNode node,
    ErrorCode errorCode, {
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
    Object? data,
  }) {
    code = errorCode;
  }

  @override
  void atToken(
    Token token,
    ErrorCode errorCode, {
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
    Object? data,
  }) {
    code = errorCode;
  }

  @Deprecated('Use atNode() instead')
  @override
  void reportErrorForNode(
    ErrorCode errorCode,
    AstNode node, [
    List<Object?>? arguments,
    List<DiagnosticMessage>? messages,
    Object? data,
  ]) {
    code = errorCode;
  }

  @Deprecated('Use atToken() instead')
  @override
  void reportErrorForToken(
    ErrorCode errorCode,
    Token token, [
    List<Object?>? arguments,
    List<DiagnosticMessage>? messages,
    Object? data,
  ]) {
    code = errorCode;
  }
}

class TestRule extends LintRule {
  static const LintCode code =
      LintCode('test_rule', 'Test rule.', correctionMessage: 'Try test rule.');

  TestRule()
      : super(
          name: 'test_rule',
          description: '',
          details: '... tl;dr ...',
          categories: {Category.errors},
        );

  @override
  LintCode get lintCode => code;
}

class _MockSource implements Source {
  @override
  final String fullName;

  _MockSource(this.fullName);

  @override
  noSuchMethod(Invocation invocation) {
    throw StateError('Unexpected invocation of ${invocation.memberName}');
  }
}
