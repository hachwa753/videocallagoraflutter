import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoapp/fetch_agora_token.dart';

// add this to android manifest .xml
//  <uses-permission android:name="android.permission.CAMERA" />
//     <uses-permission android:name="android.permission.RECORD_AUDIO" />
//     <uses-permission android:name="android.permission.INTERNET" />
//     <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

// Replace with your Agora App ID
const String appId = '6e0e73a5a42444499d40dde03af428ad';

// Token is optional for testing. Use a valid token in production!
const String token =
    '007eJxTYMjp/D5TQ/kbt0tvZvSd8+9Vjtkc1bv+X7h4c9apjGAm7/0KDGapBqnmxommiSZGJkBgaZliYpCSkmpgnJhmYmSRmLLOOTGjIZCRIYhvHQMjFIL4nAyJBQWl8YlFiUkMDAALtyFD';
// Get token from your Firebase function

// for token generation
//firebase init functions

//Navigate into the functions directory:
//cd functions
//Then install the Agora token builder:

// npm install agora-access-token

//from firebase.json file
// "predeploy": ["npm --prefix \"$RESOURCE_DIR\" run lint"] change this to =>
// "predeploy": [
//        "npm --prefix functions run lint"
//       ]

// firebase deploy --only functions

// Channel name to join
const String channelName = 'appu_arab';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await _requestPermissions(); // REQUEST PERMISSIONS
    _engine = createAgoraRtcEngine();

    await _engine.initialize(RtcEngineContext(appId: appId));

    await _engine.enableVideo();
    //  Set up local video stream
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
    //cloud firebase token
    // String token = await FetchAgoraToken().fetchAgoraToken(
    //   channelName,
    //   0,
    // ); // or your user id here

    await _engine.joinChannel(
      token: token,
      channelId: channelName,

      // uid
      //       final firebaseUid = 'ABc123xyz';
      // final agoraUid = firebaseUid.hashCode.abs();
      uid: 0, // tells agora for auto generate uid
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _requestPermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      throw Exception('Camera and Microphone permissions not granted');
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _renderLocalVideo() {
    if (_localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Center(child: Text('Joining channel...'));
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Center(child: Text('Waiting for remote user to join...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Video Call')),
      body: Stack(
        children: [
          Positioned.fill(child: _renderRemoteVideo()),
          Positioned(
            top: 20,
            left: 20,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: _renderLocalVideo(),
            ),
          ),
        ],
      ),
    );
  }
}
