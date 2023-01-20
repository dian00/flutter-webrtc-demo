import 'package:flutter_webrtc_demo/src/call_sample/signaling.dart';

enum WebRTCType { cs, user }

abstract class WebRTCCSEvent {}

class Init extends WebRTCCSEvent {
  final String? peerId;
  final WebRTCType type;
  Init({required this.type, required this.peerId});
}

class New extends WebRTCCSEvent {
  final String selfId;

  New(this.selfId);
}

class Accept extends WebRTCCSEvent {}

class Reject extends WebRTCCSEvent {}

class HangUp extends WebRTCCSEvent {}

class MuteMic extends WebRTCCSEvent {}

class RequestAccept extends WebRTCCSEvent {}

class StartCall extends WebRTCCSEvent {}

class EndCall extends WebRTCCSEvent {}

class CallStateChanged extends WebRTCCSEvent {
  final Session session;
  final CallState callState;

  CallStateChanged({required this.session, required this.callState});
}
