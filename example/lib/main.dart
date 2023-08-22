import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample_app/message_center.dart';
import 'package:pushiomanager_flutter/beacon_region.dart';
import 'package:pushiomanager_flutter/geo_region.dart';
import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sample App',
      theme: ThemeData(
          primaryColor: Color(0xffc53f34),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffc53f34),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                minimumSize: Size(250, 45)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Color(0xffc53f34),
                style: BorderStyle.solid,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 26,
            ),
          )),
      home: MyHomePage(title: 'Flutter Sample App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController userIdController = new TextEditingController();
  TextEditingController badgeCountController = new TextEditingController();
  TextEditingController iamEventController = new TextEditingController();

  @override
  void initState() {
    PushIOManager.setLogLevel(LogLevel.VERBOSE);
    super.initState();
    PushIOManager.setMessageCenterEnabled(false);
    PushIOManager.setMessageCenterEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.info_sharp, size: 15),
                          ),
                          TextSpan(
                            text:
                                " Before proceeding, make sure you have downloaded and added the pushio_config.json file in this sample app.",
                          ),
                        ],
                      ),
                    ),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Setup",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Set up the Responsys SDK using configure( ). Once the SDK is configured, call registerApp( ) to register your app with Responsys.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    configure();
                                  },
                                  child: Text('CONFIGURE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        registerApp();
                                      },
                                      child: Text('REGISTER',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("User Identification",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Use registerUserId( ) to associate this app installation with a user (usually after login). And use unregisterUserId( ) on log out.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Container(
                                    margin: const EdgeInsets.only(
                                        right: 40, left: 40),
                                    child: TextField(
                                        maxLines: 1,
                                        controller: userIdController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          hintText: "Enter user ID",
                                        ))),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        registerUserId();
                                      },
                                      child: Text('REGISTER USER ID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Engagements And Conversion",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "User actions can be attributed to a push notification using trackEngagement( )\n\nPushIOManager.EngagementType lists the different actions that can be attributed.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        trackEngagement();
                                      },
                                      child: Text('TRACK CONVERSION',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("In-App Messages",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "In-App Message (IAM) can be displayed via system-defined events like \$ExplicitAppOpen or custom events. IAM that use system-defined triggers are displayed automatically."
                                        "\n\nIAM can also be displayed on-demand using custom events."
                                        "\n\n\t- Your marketing team defines a custom event in Responsys system and shares the event name with you."
                                        "\n\n\t- The IAM is delivered to the device via push or pull mechanism (depending on your Responsys Account settings)"
                                        "\n\n\t- When you wish to display the IAM popup, call trackEvent( custom-event )",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Container(
                                    margin: const EdgeInsets.only(
                                        right: 40, left: 40),
                                    child: TextField(
                                        maxLines: 1,
                                        controller: iamEventController,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          hintText:
                                              "Enter Custom Event Trigger",
                                        ))),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        trackCustomEventForIAM();
                                      },
                                      child: Text('SHOW IN-APP MSG',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Message Center",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Get the Message Center message list using fetchMessagesForMessageCenter( )."
                                        "\n\nIf any message has rich-content(HTML) then call fetchRichContentForMessage( )."
                                        "\n\nRemember to store these messages, since the SDK cache is purgeable.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        fetchMessages();
                                      },
                                      child: Text('GET MESSAGES',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Rapid Retargeter Events",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Responsys SDK supports tracking of system-defined and custom events using trackEvent( )."
                                        "\n\nFor tracking custom events, you will need your Oracle CX - Infinity account to be setup for processing the incoming custom events. "
                                        "Your marketing team should work with your Oracle CX contact to get his done."
                                        "\n\nThe list of these events is available in the developer documentation."
                                        "\n\nFollowing are two of the supported events.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    trackEvent("\$Browsed")();
                                  },
                                  child: Text('TRACK EVENT - BROWSED',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        trackEvent("\AddedItemToCart")();
                                      },
                                      child: Text('TRACK EVENT - ADD TO CART',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Geofences And Beacons",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Record Geofence and Beacon entry/exit events using these APIs.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    onGeoRegionEntered();
                                  },
                                  child: Text('TRACK GEOFENCE ENTRY',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        onBeaconRegionEntered();
                                      },
                                      child: Text('TRACK BEACON ENTRY',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Notification Preferences",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Preferences are used to record user-choices for push notifications."
                                        "\n\nThe preferences should be pre-defined in Responsys system before being used in your app."
                                        "\n\nDo not use this as a key/value store as this data is purgeable.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    setPreference(PreferenceType.STRING)();
                                  },
                                  child: Text('SET STRING PREFERENCE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        setPreference(PreferenceType.NUMBER)();
                                      },
                                      child: Text('SET NUMBER PREFERENCE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Card(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("Set Badge Count",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
                                    child: Text(
                                        "Use this API to set the app's icon badge count to the no. of messages in the Message Center.",
                                        style:
                                            TextStyle(color: Colors.black54))),
                                Container(
                                    margin: const EdgeInsets.only(
                                        right: 40, left: 40),
                                    child: TextField(
                                        maxLines: 1,
                                        controller: badgeCountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          hintText: "Enter Badge Count",
                                        ))),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        setMessageCenterBadgeCount();
                                      },
                                      child: Text('SET BADGE COUNT',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )))
                              ],
                            ))),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Center(
                          child: Text(
                              "\u00a9 2021 Oracle and/or its affiliates. All rights reserved.",
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 10.0)),
                        ))
                  ],
                ))));
  }

  void configure() {
    PushIOManager.configure("pushio_config.json")
        .then((_) => showToast("Configuration successful"))
        .catchError((error) {
      showToast("Configuration Failed: $error");
    });
  }

  void registerApp() {
    if (Platform.isAndroid) {
      PushIOManager.registerAppForPush(true, false)
          .then((_) => showToast("Registration Successful"))
          .catchError((error) {
        showToast("Registration error: $error");
      });
    } else if (Platform.isIOS) {
      PushIOManager.registerForAllRemoteNotificationTypes().then((_) {
        PushIOManager.registerApp().then((_) {
          showToast("App Registration Successful");
        }).catchError((e) {
          showToast("App Registration failed: " + e.message);
        });
      }).catchError((e) {
        showToast("App Registration failed: " + e.message);
      });
    }
  }

  void registerUserId() {
    final String userId = userIdController.text;
    print("UserID: $userId");

    PushIOManager.registerUserId(userId);
  }

  void trackEngagement() {
    Map<String, String> props = {
      "sampleProductId": "121",
      "sampleItemCount": "5"
    };

    // PushIOManager.trackEngagement(type:EngagementType.PURCHASE,properties:props)
    PushIOManager.trackEngagement(EngagementType.PURCHASE, properties: props)
        .then((_) => showToast("Engagement Reported Successfully"))
        .catchError((error) => showToast("Engagement not reported: $error"));
  }

  void trackCustomEventForIAM() {
    final String event = iamEventController.text;

    PushIOManager.trackEvent(event, properties: null);
  }

  void fetchMessages() {
    PushIOManager.fetchMessagesForMessageCenter("Primary").then((messages) => {
          if (messages != null && messages.isNotEmpty)
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MessageCenterPage(messages: messages)))
            }
          else
            {showToast("No Message Center Messages")}
        });
  }

  trackEvent(String eventName) {
    Map<String, String> props = {"Pid": "1", "Pc": "sampleProduct"};

    PushIOManager.trackEvent(eventName, properties: props)
        .then((_) => showToast("Event recorded successfully"))
        .catchError((error) => showToast("Event not recorded: $error"));
  }

  void onGeoRegionEntered() {
    GeoRegion region = new GeoRegion("id1", "geofence1", "zone1", "zoneId1",
        "testSource", 20.0, 55.0, 25, null);

    PushIOManager.onGeoRegionEntered(region)
        .then((response) => showToast(
            "$response['regionType'] with ID - $response['regionID'] successfully reported"))
        .catchError((error) =>
            showToast("Unable to report \$GEOFENCE_ENTRY event: $error"));
  }

  void onBeaconRegionEntered() {
    BeaconRegion region = new BeaconRegion(
        "beaconId",
        "beaconName",
        "beaconTag",
        "beaconProximity",
        "iBeaconUUID",
        1,
        10,
        "eddyStoneId1",
        "eddyStoneId2",
        "zoneName",
        "zoneId",
        "source",
        25,
        null);

    PushIOManager.onBeaconRegionEntered(region)
        .then((response) => showToast(
            "$response['regionType'] with ID - $response['regionID'] successfully reported"))
        .catchError((error) =>
            showToast("Unable to report \$BEACON_ENTRY event: $error"));
  }

  setPreference(PreferenceType preferenceType) {
    const String key = "sampleKey";

    PushIOManager.declarePreference(key, "Label to show in UI", preferenceType)
        .then((_) => {
              showToast("Preference declared successfully"),
              if (preferenceType == PreferenceType.NUMBER)
                {
                  PushIOManager.setNumberPreference(key, 1)
                      .then((_) => showToast("Preference set successfully"))
                      .catchError(
                          (error) => showToast("Preference not set: $error"))
                }
              else
                {
                  PushIOManager.setStringPreference(key, "Test Value")
                      .then((_) => showToast("Preference set successfully"))
                      .catchError(
                          (error) => showToast("Preference not set: $error"))
                }
            })
        .catchError(
            (error) => {showToast("Preference could not be declared: $error")});
  }

  void setMessageCenterBadgeCount() {
    int badgeCount = 0;

    if (badgeCountController.text.isNotEmpty) {
      badgeCount = int.parse(badgeCountController.text);
    }

    print("Badge count is $badgeCount");

    PushIOManager.setBadgeCount(badgeCount, forceSetBadge: true)
        .then((_) => showToast("Badge count updated successfully"))
        .catchError((error) => showToast("Unable to set badge count: $error"));
  }

  showToast(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
