import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc_demo/main.dart';
import 'package:flutter_webrtc_demo/src/call_sample/user_popup.dart';
import 'package:flutter_webrtc_demo/src/route_item.dart';

import 'call_sample/cs_popup.dart';

class MainScreen extends StatefulWidget {
  final PendingDynamicLinkData? link;

  const MainScreen({required this.link});
  @override
  _MainScreenState createState() => new _MainScreenState();
}

enum DialogDemoAction {
  cancel,
  connect,
}

class _MainScreenState extends State<MainScreen> {
  List<RouteItem> items = [];
  String _server = ttgoWebRTCServer;

  @override
  initState() {
    super.initState();

    if (widget.link != null) {
      final Uri? deepLink = widget.link!.link;
      if (deepLink != null) {
        print("deepLink: ${deepLink.toString()}");
        final String? peerId = deepLink.queryParameters["peerId"];
        print('peerId = $peerId');
        Future.delayed(Duration.zero, () {
          showDialog(context: context, builder: ((context) => UserPopup(peerId: peerId)));
        });
      }
    }
    // _initData();
    _initItems();
  }

  _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ttgo-WebRTC Sample'),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return _buildRow(context, items[i]);
          }),
    );
  }

  _initItems() {
    items = <RouteItem>[
      RouteItem(
          title: 'Customer Service (For User) 1',
          subtitle: 'P2P Call Sample.',
          push: (BuildContext context) {
            showDialog(context: context, builder: ((context) => UserPopup(peerId: "1234")));
          }),
      RouteItem(
          title: 'Customer Service (For CS) 2',
          subtitle: 'P2P Call Sample.',
          push: (BuildContext context) {
            showDialog(context: context, builder: ((context) => CSPopup()));
          }),
    ];
  }
}
