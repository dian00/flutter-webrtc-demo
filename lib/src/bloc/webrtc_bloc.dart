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

  String? _selfId = randomNumeric(6);

  WebRTCType _type = WebRTCType.cs;

  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;

  WebRTCCSBloc(WebRTCCSState initialState) : super(initialState);

  @override
  Stream<WebRTCCSState> mapEventToState(WebRTCCSEvent event) async* {
    print('mapEventToState :: ${event.toString()}');
    if (event is Init) {
      yield WebRTCCSInitial();
      _type = event.type;
      await initRenderers();
      yield* _connect(_selfId, event.peerId);
    } else if (event is Accept) {
      _accept();
      yield InCalling(_localRenderer!, _remoteRenderer!);
    } else if (event is Reject) {
      _reject();
    } else if (event is HangUp) {
      _hangUp();
      _deactiveSignaling();
    } else if (event is MuteMic) {
      _muteMic();
    } else if (event is RequestAccept) {
      yield WaitingAccept();
    } else if (event is New) {
      _signaling?.createNew(event.selfId);
      if (_type == WebRTCType.user) {
        // yield ConnectionOpened(_selfId);
      } else {
        String? link = await DynamicLinkHelper.buildDynamicLinks(event.selfId);
        yield ConnectionOpened(link);
      }
    } else if (event is CallStateChanged) {
      switch (event.callState) {
        case CallState.CallStateNew:
          _session = event.session;
          break;
        case CallState.CallStateRinging:
          // yield Ringing();
          _accept();
          yield InCalling(_localRenderer!, _remoteRenderer!);
          break;
        case CallState.CallStateBye:
          yield EndedCall();
          _localRenderer!.srcObject = null;
          _remoteRenderer!.srcObject = null;
          _session = null;
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

  Stream<WebRTCCSState> _connect(String? selfId, String? peerId) async* {
    print('_connect : $selfId, $peerId');
    _signaling ??= Signaling(ttgoWebRTCServer, null)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) async {
      print("onSignalingStateChange: ${state.name}");
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
          break;
        case SignalingState.ConnectionOpen:
          add(New(selfId!));
          // await _signaling?.createNew(selfId);
          // await _initForegroundTask();
          if (_type == WebRTCType.user && peerId != null) invitePeer(peerId, true);
          break;
      }
    };

    _signaling?.onCallStateChange = (Session s, CallState cState) async {
      print("onCallStateChange: ${cState.name}");
      add(CallStateChanged(session: s, callState: cState));
    };

    _signaling?.onLocalStream = ((stream) {
      _localRenderer?.srcObject = stream;
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      _remoteRenderer?.srcObject = stream;
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer?.srcObject = null;
    });
  }

  invitePeer(String peerId, bool useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling?.invite(peerId, 'video', useScreen);
    }
  }

  _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
    }
  }

  _reject() {
    if (_session != null) {
      _signaling?.reject(_session!.sid);
    }
  }

  _hangUp() async {
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
    _signaling?.close();
    _signaling = null;
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
  }
}
