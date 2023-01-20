import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class WebRTCCSState {}

class WebRTCCSInitial extends WebRTCCSState {}

class ConnectionOpened extends WebRTCCSState {
  final String? selfId;

  ConnectionOpened(this.selfId);
}

class Ready extends WebRTCCSState {}

class WaitingAssign extends WebRTCCSState {}

class WaitingAccept extends WebRTCCSState {}

class WaitingInvite extends WebRTCCSState {}

class Ringing extends WebRTCCSState {}

class InCalling extends WebRTCCSState {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  InCalling(this.localRenderer, this.remoteRenderer);
}

class EndedCall extends WebRTCCSState {}
