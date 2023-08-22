// Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

class BeaconRegion {
  final String? beaconId;
  final String? beaconName;
  final String? beaconTag;
  final String? beaconProximity;
  final String? iBeaconUUID;
  final int? iBeaconMajor;
  final int? iBeaconMinor;
  final String? eddyStoneId1;
  final String? eddyStoneId2;
  final String? zoneName;
  final String? zoneId;
  final String? source;
  final int? dwellTime;
  final Map<String, String>? extra;

  BeaconRegion(
      this.beaconId,
      this.beaconName,
      this.beaconTag,
      this.beaconProximity,
      this.iBeaconUUID,
      this.iBeaconMajor,
      this.iBeaconMinor,
      this.eddyStoneId1,
      this.eddyStoneId2,
      this.zoneName,
      this.zoneId,
      this.source,
      this.dwellTime,
      this.extra);

  static BeaconRegion fromJson(dynamic json) {
    return BeaconRegion(
        json['beaconId'],
        json['beaconName'],
        json['beaconTag'],
        json['beaconProximity'],
        json['iBeaconUUID'],
        json['iBeaconMajor'] as int?,
        json['iBeaconMinor'] as int?,
        json['eddyStoneId1'],
        json['eddyStoneId2'],
        json['zoneName'],
        json['zoneId'],
        json['source'],
        json['dwellTime'] as int?,
        json['extra']);
  }

  Map<String, dynamic> toJson() => {
        'beaconId': beaconId,
        'beaconName': beaconName,
        'beaconTag': beaconTag,
        'beaconProximity': beaconProximity,
        'iBeaconUUID': iBeaconUUID,
        'iBeaconMajor': iBeaconMajor,
        'iBeaconMinor': iBeaconMinor,
        'eddyStoneId1': eddyStoneId1,
        'eddyStoneId2': eddyStoneId2,
        'zoneName': zoneName,
        'zoneId': zoneId,
        'source': source,
        'dwellTime': dwellTime,
        'extra': extra
      };
}
