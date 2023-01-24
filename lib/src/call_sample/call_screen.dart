import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_event.dart';
import 'dart:core';

import 'package:flutter_webrtc_demo/src/bloc/webrtc_state.dart';

class CallScreen extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const CallScreen({required this.localRenderer, required this.remoteRenderer});
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String? _selfId;

  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebRTCCSBloc, WebRTCCSState>(
      listener: (context, state) {
        if (state is EndedCall) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text((_selfId != null ? '[ Your ID : $_selfId ]' : 'Call Sample')),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
            width: 150.0,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  BlocProvider.of<WebRTCCSBloc>(context).add(HangUp());
                  Navigator.pop(context);
                }, //_hangUp,
                tooltip: 'Hangup',
                child: Icon(Icons.call_end),
                backgroundColor: Colors.pink,
              ),
              FloatingActionButton(
                child: const Icon(Icons.mic_off),
                tooltip: 'Mute Mic',
                onPressed: () {
                  BlocProvider.of<WebRTCCSBloc>(context).add(MuteMic());
                }, //_muteMic,
              )
            ])),
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: RTCVideoView(widget.remoteRenderer),
                    decoration: BoxDecoration(color: Colors.black54),
                  )),
            ]),
          );
        }),
      ),
    );
  }
}
