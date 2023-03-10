// Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';
import 'package:pushiomanager_flutter/utils.dart';

class Preference {
  final String key;
  final String label;
  final dynamic value;
  final PreferenceType type;

  Preference(this.key, this.label, this.value, this.type);

  static Preference fromJson(dynamic json) {
    return Preference(json['key'], json['label'], json['value'],
        preferenceTypeFromString(json['type']));
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'value': value,
        'type': preferenceTypeToString(type)
      };
}
