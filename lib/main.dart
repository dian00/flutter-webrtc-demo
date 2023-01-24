import 'dart:core';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_bloc.dart';
import 'package:flutter_webrtc_demo/src/bloc/webrtc_state.dart';
import 'package:flutter_webrtc_demo/src/main_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PendingDynamicLinkData? initLink;
  if (Platform.isAndroid || Platform.isIOS) initLink = await FirebaseDynamicLinks.instance.getInitialLink();

  FirebaseDynamicLinks.instance.onLink.listen((linkData) {
    print('onLink: ${linkData.link}');
  }).onError((error) {
    print('onLinkError: $error');
  });

  runApp(BlocProvider(lazy: false, create: (_) => WebRTCCSBloc(WebRTCCSInitial()), child: MyApp(link: initLink)));
}

class MyApp extends StatelessWidget {
  final PendingDynamicLinkData? link;

  const MyApp({this.link});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(link: link),
    );
  }
}

const String ttgoWebRTCServer = "demo.cloudwebrtc.com";
