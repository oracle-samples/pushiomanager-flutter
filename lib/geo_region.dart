// Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

class GeoRegion {
  final String? geofenceId;
  final String? geofenceName;
  final String? zoneName;
  final String? zoneId;
  final String? source;
  final double? deviceBearing;
  final double? deviceSpeed;
  final int? dwellTime;
  final Map<String, String>? extra;

  GeoRegion(
      this.geofenceId,
      this.geofenceName,
      this.zoneName,
      this.zoneId,
      this.source,
      this.deviceBearing,
      this.deviceSpeed,
      this.dwellTime,
      this.extra);

  static GeoRegion fromJson(dynamic json) {
    return GeoRegion(
        json['geofenceId'],
        json['geofenceName'],
        json['zoneName'],
        json['zoneId'],
        json['source'],
        json['deviceBearing'] as double?,
        json['deviceSpeed'] as double?,
        json['dwellTime'] as int?,
        json['extra']);
  }

  Map<String, dynamic> toJson() => {
        'geofenceId': geofenceId,
        'geofenceName': geofenceName,
        'zoneName': zoneName,
        'zoneId': zoneId,
        'source': source,
        'deviceBearing': deviceBearing,
        'deviceSpeed': deviceSpeed,
        'dwellTime': dwellTime,
        'extra': extra
      };
}
