import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_event.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_state.dart';
import 'package:flutter_webrtc_demo/src/call_sample/call_screen.dart';

class UserPopup extends StatefulWidget {
  final String? peerId;
  UserPopup({required this.peerId});
  @override
  State<UserPopup> createState() => _UserPopupState();
}

class _UserPopupState extends State<UserPopup> {
  @override
  void initState() {
    BlocProvider.of<WebRTCCSBloc>(context).add(Init(type: WebRTCType.user, peerId: widget.peerId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebRTCCSBloc, WebRTCCSState>(
      listener: (context, state) {
        if (state is InCalling) {
          Navigator.of(context).pop();

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
            } else if (state is WaitingAccept) {
              return AlertDialog(
                title: Text("title"),
                content: Text("waiting"),
                actions: <Widget>[
                  TextButton(
                    child: Text("cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      // _hangUp();
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
                    },
                  ),
                ],
              );
            }

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
          }),
    );
  }
}
