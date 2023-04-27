import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_demo/main.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_event.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_state.dart';
import 'package:flutter_webrtc_demo/src/call_sample/random_string.dart';
import 'package:flutter_webrtc_demo/src/call_sample/signaling.dart';
import 'package:flutter_webrtc_demo/src/utils/dynamic_link_helper.dart';

class WebRTCCSBloc extends Bloc<WebRTCCSEvent, WebRTCCSState> {
  Signaling? _signaling;
  Session? _session;

  String? _selfId;

  WebRTCType _type = WebRTCType.cs;

  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;

  WebRTCCSBloc(WebRTCCSState initialState) : super(initialState);

  @override
  Stream<WebRTCCSState> mapEventToState(WebRTCCSEvent event) async* {
    print('[WebRTCBloc] mapEventToState :: ${event.toString()}');
    if (event is Init) {
      yield WebRTCCSInitial();
      _type = event.type;
      await initRenderers();
      yield* _connect(_selfId = randomNumeric(6), event.peerId, event.context);
    } else if (event is Accept) {
      _accept();
      yield InCalling(_localRenderer!, _remoteRenderer!);
    } else if (event is Reject) {
      _reject();
    } else if (event is HangUp) {
      _hangUp();
      _deactiveSignaling();
      yield EndedCall();
    } else if (event is MuteMic) {
      _muteMic();
    } else if (event is RequestAccept) {
      yield WaitingAccept();
    } else if (event is New) {
      _signaling?.createNew(event.selfId);
      if (_type == WebRTCType.cs) {
        String? link = await DynamicLinkHelper.buildDynamicLinks(event.selfId);
        yield ConnectionOpened(link);
      }
    } else if (event is EndCall) {
      await _deactiveSignaling();
      yield EndedCall();
    } else if (event is CallStateChanged) {
      switch (event.callState) {
        case CallState.CallStateNew:
          _session = event.session;
          break;
        case CallState.CallStateRinging:
          _accept();
          yield InCalling(_localRenderer!, _remoteRenderer!);
          break;
        case CallState.CallStateBye:
          if (_session!.sid == event.session.sid) {
            _deactiveSignaling();
            yield EndedCall();
          }
          break;
        case CallState.CallStateInvite:
          add(RequestAccept());
          break;
        case CallState.CallStateConnected:
          yield InCalling(_localRenderer!, _remoteRenderer!);
          break;
      }
    }
  }

  initRenderers() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer?.initialize();
    await _remoteRenderer?.initialize();
  }

  Stream<WebRTCCSState> _connect(String? selfId, String? peerId, BuildContext context) async* {
    print('[WebRTCBloc] _connect : $selfId, $peerId');
    _signaling ??= Signaling(ttgoWebRTCServer, context)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) async {
      print("[WebRTCBloc] onSignalingStateChange: ${state.name}");
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
          if (WebRTC.platformIsAndroid) FlutterBackground.disableBackgroundExecution();
          if (state is EndedCall == false) {
            add(EndCall());
          }
          break;
        case SignalingState.ConnectionOpen:
          add(New(selfId!));
          if (_type == WebRTCType.user && peerId != null) invitePeer(peerId, true);
          break;
      }
    };

    _signaling?.onCallStateChange = (Session s, CallState cState) async {
      print("[WebRTCBloc] onCallStateChange: ${cState.name}");
      add(CallStateChanged(session: s, callState: cState));
    };

    _signaling?.onLocalStream = ((stream) {
      print("[WebRTCBloc] onLocalStream");
      _localRenderer?.srcObject = stream;
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      print("[WebRTCBloc] onAddRemoteStream");
      _remoteRenderer?.srcObject = stream;
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      print("[WebRTCBloc] onRemoveRemoteStream: $stream");
      _remoteRenderer?.srcObject = null;
    });

    _signaling?.onPeersUpdate = ((peers) {
      print("[WebRTCBloc] onPeersUpdate: $peers");
    });
  }

  invitePeer(String peerId, bool useScreen) async {
    print('[WebRTCBloc] invitePeer : $peerId');
    if (_signaling != null && peerId != _selfId) {
      bool service = true;
      if (WebRTC.platformIsAndroid) service = await startForegroundService();
      if (service) _signaling?.invite(peerId, 'video', useScreen);
    }
  }

  _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
    }
  }

  _reject() {
    print("[WebRTCBloc] reject()");

    if (_session != null) {
      _signaling?.reject(_session!.sid);
    }
  }

  _hangUp() async {
    print("[WebRTCBloc] hangUp()");
    if (_session != null) {
      _signaling?.bye(_session!.sid);
    }
  }

  _muteMic() {
    if (_session != null) {
      _signaling?.muteMic();
    }
  }

  _deactiveSignaling() {
    _session = null;

    _signaling?.close();
    _signaling = null;
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();

    _localRenderer!.srcObject = null;
    _remoteRenderer!.srcObject = null;
  }

  Future<bool> startForegroundService() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
  }
}
