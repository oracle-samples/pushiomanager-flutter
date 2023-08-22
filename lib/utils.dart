// Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import 'dart:io' show Platform;

import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';

int engagementTypeToInt(EngagementType type) {
  switch (type) {
    case EngagementType.LAUNCH:
      return 1;
    case EngagementType.ACTIVE_SESSION:
      return 2;
    case EngagementType.INAPP_PURCHASE:
      return 3;
    case EngagementType.PREMIUM_CONTENT:
      return 4;
    case EngagementType.SOCIAL:
      return 5;
    case EngagementType.OTHER:
      return 6;
    case EngagementType.PURCHASE:
      return 7;
    default:
      return 0;
  }
}

EngagementType engagementTypeFromInt(int type) {
  return EngagementType.values
      .singleWhere((element) => engagementTypeToInt(element) == type);
}

String? preferenceTypeToString(PreferenceType type) {
  switch (type) {
    case PreferenceType.STRING:
      return "STRING";
    case PreferenceType.NUMBER:
      return "NUMBER";
    case PreferenceType.BOOLEAN:
      return "BOOLEAN";
    default:
      return null;
  }
}

PreferenceType preferenceTypeFromString(String? type) {
  return PreferenceType.values
      .singleWhere((element) => preferenceTypeToString(element) == type);
}

int loglevelToInt(LogLevel logLevel) {
  if (Platform.isAndroid) {
    switch (logLevel) {
      case LogLevel.NONE:
        return 0;
      case LogLevel.ERROR:
        return 6;
      case LogLevel.WARN:
        return 5;
      case LogLevel.INFO:
        return 4;
      case LogLevel.DEBUG:
        return 3;
      case LogLevel.VERBOSE:
        return 2;
      default:
        return -1;
    }
  } else if (Platform.isIOS) {
    switch (logLevel) {
      case LogLevel.NONE:
        return 0;
      case LogLevel.ERROR:
        return 1;
      case LogLevel.WARN:
        return 2;
      case LogLevel.INFO:
        return 3;
      case LogLevel.DEBUG:
        return 4;
      case LogLevel.VERBOSE:
        return 5;
      default:
        return -1;
    }
  } else {
    return -1;
  }
}
