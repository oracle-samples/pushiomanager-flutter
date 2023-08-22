import 'package:flutter/material.dart';
import 'package:pushiomanager_flutter/messagecenter_message.dart';
import 'package:pushiomanager_flutter/pushiomanager_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessageCenterPage extends StatefulWidget {
  final List<MessageCenterMessage> messages;

  MessageCenterPage({Key? key, required this.messages}) : super(key: key);

  @override
  _MessageCenterPageState createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage> {
  @override
  void initState() {
    PushIOManager.onMessageCenterViewVisible();
    super.initState();
  }

  @override
  void dispose() {
    PushIOManager.onMessageCenterViewFinish();
    super.dispose();
  }

  static Route<Object> _dialogBuilder(BuildContext context, Object? arguments) {
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(arguments as String),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"))
        ],
      ),
    ) as Route<Object>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Message Center'),
        ),
        body: ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Colors.black45,
                ),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              return VisibilityDetector(
                  key: Key(index.toString()),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction == 1) {
                      PushIOManager.trackMessageCenterDisplayEngagement(
                          widget.messages[index].messageID);
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.messages[index].iconURL!),
                    ),
                    title: Text(widget.messages[index].subject!),
                    subtitle: Text(widget.messages[index].message!),
                    onTap: () {
                      onMessageSelected(widget.messages[index]);
                    },
                  ));
            }));
  }

  void onMessageSelected(MessageCenterMessage message) {
    PushIOManager.fetchRichContentForMessage(message.messageID)
        .then((response) => showRichContent(message, response))
        .catchError(
            (error) => showToast("Error fetching rich content: $error"));
  }

  showRichContent(MessageCenterMessage message, Map<String, String> response) {
    String? richContentHtml;
    if (response['richContent'] != null) {
      richContentHtml = response['richContent'];
    } else {
      richContentHtml = message.message;
    }

    Navigator.of(context)
        .restorablePush(_dialogBuilder, arguments: richContentHtml);

    PushIOManager.trackMessageCenterOpenEngagement(message.messageID);
  }

  showToast(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
