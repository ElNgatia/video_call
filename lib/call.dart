import 'dart:html';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/src/render/agora_video_view.dart'
    as rtc_local_view;
import 'package:agora_rtc_engine/src/render/video_view_controller.dart'
    as rtc_remote_view;
import 'package:video_call/settings.dart';

class CallPage extends StatefulWidget {
  final String? channelName;
  final ClientRoleType? role;
  const CallPage({super.key, this.channelName, this.role});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;

  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // destroy sdk
    _engine.leaveChannel();
    _engine.stopPreview();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'AppId missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    _engine = createAgoraRtcEngine();
    await _engine.enableVideo();
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: widget.role!);

    _addAgoraEventHandlers();
    VideoEncoderConfiguration config = const VideoEncoderConfiguration();
    VideoDimensions dimensions = const Size(1280, 720) as VideoDimensions;
    await _engine.setVideoEncoderConfiguration(config);
    await _engine.joinChannel(
        token: token,
        channelId: '',
        options: const ChannelMediaOptions(),
        uid: 0);
  }

  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          setState(() {
            final info = 'onError: $err $msg';
            _infoStrings.add(info);
          });
        },
        onJoinChannelSuccess: (channel, elapsed) {
          setState(() {
            final info = 'onJoinChannel: $channel';
            _infoStrings.add(info);
          });
        },
        onLeaveChannel: (channel, stats) async {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
          });
        },
        onUserJoined: (channel, uid, elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        onUserOffline: (channel, uid, elapsed) {
          setState(() {
            final info = 'userOffline: $uid';
            _infoStrings.add(info);
            _users.remove(uid);
          });
        },
        onFirstRemoteVideoFrame: (channel, uid, width, height, elapsed) {
          setState(() {
            final info = 'firstRemoteVideo: $uid ${width}x $height';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  // Toolbar layout
  Widget _viewRows() {
    final List<StatefulWidgetBuilder> list = [];
    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      list.add(
          VideoViewController(rtcEngine: _engine, canvas: const VideoCanvas(uid: 0)) as StatefulWidgetBuilder);
    }
  }




  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Join channel'),
          onPressed: () {
            // TODO
          },
        ),
      ),
    );
  }
}
