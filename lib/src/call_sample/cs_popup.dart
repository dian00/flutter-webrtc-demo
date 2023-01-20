import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_event.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_state.dart';
import 'package:flutter_webrtc_demo/src/call_sample/call_screen.dart';

class CSPopup extends StatefulWidget {
  @override
  State<CSPopup> createState() => _CSPopupState();
}

class _CSPopupState extends State<CSPopup> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<WebRTCCSBloc>(context).add(Init(type: WebRTCType.cs, peerId: null));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebRTCCSBloc, WebRTCCSState>(
        listener: (context, state) {
          if (state is InCalling) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CallScreen(localRenderer: state.localRenderer, remoteRenderer: state.remoteRenderer)));
          }
        },
        child: BlocBuilder<WebRTCCSBloc, WebRTCCSState>(
            bloc: BlocProvider.of<WebRTCCSBloc>(context),
            builder: (context, state) {
              if (state is WebRTCCSInitial) {
                return AlertDialog(
                  content: Text("Loading..."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        //
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              } else if (state is ConnectionOpened) {
                return AlertDialog(
                  content: Text("Your ID: ${state.selfId}"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        //
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              } else if (state is Ringing) {
                return AlertDialog(
                  title: Text("title"),
                  content: Text("accept?"),
                  actions: <Widget>[
                    MaterialButton(
                      child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        BlocProvider.of<WebRTCCSBloc>(context).add(Reject());
                      },
                    ),
                    MaterialButton(
                      child: Text(
                        'Accept',
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        BlocProvider.of<WebRTCCSBloc>(context).add(Accept());
                        Navigator.of(context).pop();
                        // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CallScreen()));
                      },
                    ),
                  ],
                );
              }

              return AlertDialog(
                content: Text("Loading.EEE.."),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      //
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }));
  }
}
