// Copyright © 2026, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('pushiomanager_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLibVersion') {
        return '7.1.6';
      } else if (methodCall.method == 'getAPIKey') {
        return null;
      } else {
        return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await PushIOManager.getLibVersion(), '7.1.6');
  });

  test('getAPIKey', () async {
    expect(await PushIOManager.getAPIKey(), null);
  });

  test('getAccountToken', () async {
    expect(await PushIOManager.getAccountToken(), null);
  });

  test('getPreferences', () async {
    expect(await PushIOManager.getPreferences(), null);
  });

  test('getPreference', () async {
    expect(await PushIOManager.getPreference("key"), null);
  });
}
