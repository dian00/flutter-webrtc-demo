import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_demo/main.dart';
import 'package:flutter_webrtc_demo/src/route_item.dart';

import 'call_sample/cs_popup.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => new _MainScreenState();
}

enum DialogDemoAction {
  cancel,
  connect,
}

class _MainScreenState extends State<MainScreen> {
  List<RouteItem> items = [];

  @override
  initState() {
    super.initState();
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
        title: Text('ttgo-WebRTC Demo'),
      ),
      body: WebRTC.platformIsAndroid || WebRTC.platformIsIOS
          ? Center(child: Text("Waiting for WebRTC connection..."))
          : ListView.builder(
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
          title: 'CS DEMO (MENU FOR CS)',
          push: (BuildContext context) {
            showDialog(context: context, builder: ((context) => CSPopup()));
          }),
    ];
  }
}
