// Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

class InteractiveNotificationCategory {
  String? category;
  List<InteractiveNotificationButton>? notificationButtons;

  InteractiveNotificationCategory(this.category, this.notificationButtons);

  static InteractiveNotificationCategory fromJson(dynamic json) {
    return InteractiveNotificationCategory(
        json['orcl_category'],
        json['orcl_btns'].map<InteractiveNotificationButton>((dynamic payload) {
          return InteractiveNotificationButton.fromJson(payload);
        }).toList());
  }

  Map<String, dynamic> toJson() => {
        'orcl_category': category,
        'orcl_btns': notificationButtons!.map((e) => e.toJson()).toList()
      };
}

class InteractiveNotificationButton {
  String? id;
  String? action;
  String? label;

  InteractiveNotificationButton(this.id, this.action, this.label);

  static InteractiveNotificationButton fromJson(dynamic json) {
    return InteractiveNotificationButton(
        json['id'], json['action'], json['label']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'action': action, 'label': label};
}
