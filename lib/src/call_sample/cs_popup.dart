import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    if (BlocProvider.of<WebRTCCSBloc>(context).state is ConnectionOpened == false) {
      BlocProvider.of<WebRTCCSBloc>(context).add(Init(context, type: WebRTCType.cs, peerId: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebRTCCSBloc, WebRTCCSState>(
        listener: (context, state) {
          if (state is InCalling) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        CallScreen(user: false, localRenderer: state.localRenderer, remoteRenderer: state.remoteRenderer)));
          } else if (state is EndedCall) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<WebRTCCSBloc, WebRTCCSState>(
            bloc: BlocProvider.of<WebRTCCSBloc>(context),
            builder: (context, state) {
              if (state is ConnectionOpened) {
                return AlertDialog(
                  content: Row(children: [
                    Text("cs link : ${state.selfId}"),
                    IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: state.selfId));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coppied to your clipboard !")));
                        })
                  ]),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        BlocProvider.of<WebRTCCSBloc>(context).add(HangUp());
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
                        BlocProvider.of<WebRTCCSBloc>(context).add(Reject());
                        Navigator.of(context).pop();
                      },
                    ),
                    MaterialButton(
                      child: Text(
                        'Accept',
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        BlocProvider.of<WebRTCCSBloc>(context).add(Accept());
                        // Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }

              return AlertDialog(
                content: Text("Loading..."),
              );
            }));
  }
}
