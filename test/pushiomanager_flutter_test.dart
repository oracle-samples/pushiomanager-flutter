// Copyright © 2026, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';

void main() {
  const channel = MethodChannel('pushiomanager_flutter');
  final calls = <MethodCall>[];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      calls.add(methodCall);
      switch (methodCall.method) {
        case 'getLibVersion':
          return '7.1.6';
        case 'isSDKEnabled':
        case 'isUserIDExcludedFromUBI':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('reads SDK metadata', () async {
    expect(await PushIOManager.getLibVersion(), '7.1.6');
    expect(await PushIOManager.getAPIKey(), isNull);
    expect(await PushIOManager.getAccountToken(), isNull);
  });

  test('returns typed Android feature flags', () async {
    expect(await PushIOManager.isSDKEnabled(), isTrue);
    expect(await PushIOManager.isUserIDExcludedFromUBI(), isTrue);
  });

  test('sends multiple-reference values over the channel', () async {
    await PushIOManager.setReferences(['card-1', 'card-2']);
    await PushIOManager.setCurrentActiveReference('card-2');

    expect(calls[0].method, 'setReferences');
    expect(calls[0].arguments, ['card-1', 'card-2']);
    expect(calls[1].method, 'setCurrentActiveReference');
    expect(calls[1].arguments, 'card-2');
  });

  test('returns null for missing preferences', () async {
    expect(await PushIOManager.getPreferences(), isNull);
    expect(await PushIOManager.getPreference('key'), isNull);
  });
}
