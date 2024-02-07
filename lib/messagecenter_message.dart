// Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

class MessageCenterMessage {
  final String messageID;
  final String? subject;
  final String? message;
  final String? iconURL;
  final String? messageCenterName;
  final String? deeplinkURL;
  final String? richMessageHTML;
  final String? richMessageURL;
  final String? sentTimestamp;
  final String? expiryTimestamp;
  final Map<String, String>? customKeyValuePairs;

  MessageCenterMessage(
      this.messageID,
      this.subject,
      this.message,
      this.iconURL,
      this.messageCenterName,
      this.deeplinkURL,
      this.richMessageHTML,
      this.richMessageURL,
      this.sentTimestamp,
      this.expiryTimestamp,
      this.customKeyValuePairs);

  static MessageCenterMessage fromJson(dynamic json) {
    return MessageCenterMessage(
        json['messageID'],
        json['subject'],
        json['message'],
        json['iconURL'],
        json['messageCenterName'],
        json['deeplinkURL'],
        json['richMessageHTML'],
        json['richMessageURL'],
        json['sentTimestamp'],
        json['expiryTimestamp'],
        (json['customKeyValuePairs'] != null)
            ? Map<String, String>.from(json['customKeyValuePairs'])
            : null);
  }

  Map<String, dynamic> toJson() => {
        'messageID': messageID,
        'subject': subject,
        'message': message,
        'iconURL': iconURL,
        'messageCenterName': messageCenterName,
        'deeplinkURL': deeplinkURL,
        'richMessageHTML': richMessageHTML,
        'richMessageURL': richMessageURL,
        'sentTimestamp': sentTimestamp,
        'expiryTimestamp': expiryTimestamp,
        'customKeyValuePairs': customKeyValuePairs
      };
}
