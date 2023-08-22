// Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';
import 'package:pushiomanager_flutter/utils.dart';
import 'dart:io';

class ConversionEvent {
  String? orderId;
  double? orderTotal;
  int? orderQuantity;
  late EngagementType conversionType;
  Map<String, String>? customProperties;

  ConversionEvent(String? orderId, double? orderTotal, int? orderQuantity,
      EngagementType conversionType, Map<String, String>? customProperties) {
    this.orderId = orderId;
    this.orderTotal = orderTotal;
    this.orderQuantity = orderQuantity;
    this.customProperties = customProperties;

    if (Platform.isIOS) {
      int engagementMetric = engagementTypeToInt(conversionType);
      engagementMetric =
          ((engagementMetric < 6) ? (engagementMetric - 1) : engagementMetric);
      this.conversionType = engagementTypeFromInt(engagementMetric);
    } else {
      this.conversionType = conversionType;
    }
  }

  static ConversionEvent fromJson(dynamic json) {
    return ConversionEvent(
        json['orderId'],
        json['orderTotal'] as double?,
        json['orderQuantity'] as int?,
        engagementTypeFromInt(json['conversionType'] as int),
        json['customProperties']);
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'orderTotal': orderTotal,
        'orderQuantity': orderQuantity,
        'conversionType': engagementTypeToInt(conversionType),
        'customProperties': customProperties
      };
}
