import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive/hive.dart';
import 'package:hugb/config/db_paths.dart';
import 'package:hugb/services/signalling.service.dart';

class AudioCallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  final String callName;
  const AudioCallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.callName,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final client = Client()
      .setEndpoint(DbPaths.projectEndPoint) // Your Appwrite Endpoint
      .setProject(DbPaths.project) // Your project ID
      .setSelfSigned();
  var box = Hive.box('myData');
  final String websocketUrl = "https://websocket-server.fly.dev/";

  final String roomCollection = '658cc51add6d6041542c';
  final String databaseId = '658719d096c0de092236';
  final String iceCandidateCollection = '65935efacb288698fb73';
  final String answerCallCollection = '6593610ee00e4c1afd8a';
  final String makeCallCollection = '659362945d9e6589c9fd';

  // socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  @override
  void initState() {
    // init signalling service
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: box.get('id'),
    );
    // initializing renderers
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    // setup Peer Connection
    _setupPeerConnection();
    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = true;
    });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _setupPeerConnection() async {
    Databases database = Databases(client);

    final realtime = Realtime(client);
    // create peer connection
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // set source for local video renderer
    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    // for Incoming call
    if (widget.offer != null) {
      // listen for Remote IceCandidate
      socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];

        // add iceCandidate
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });

      // set SDP offer as remoteDescription for peerConnection
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      // create SDP answer
      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      // set SDP answer as localDescription for peerConnection
      _rtcPeerConnection!.setLocalDescription(answer);

      // send SDP answer to remote peer over signalling
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      await database.createDocument(
        databaseId: databaseId,
        collectionId: answerCallCollection,
        documentId: uniqueId,
        data: {
          "callerId": widget.callerId,
          'sdp': answer.sdp,
          'type': answer.type,
        },
      );
      socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "sdpAnswer": answer.toMap(),
      });
    }
    // for Outgoing Call
    else {
      // listen for local iceCandidate and add it to the list of IceCandidate
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      // when call is accepted by remote peer
      final subscription = realtime.subscribe([
        'databases.$databaseId.collections.$answerCallCollection.documents'
      ]);

      subscription.stream.listen((response) async {
        // print(response.payload);
        if (response.events
            .contains("databases.*.collections.*.documents.*.create")) {
          // print(response.payload);
          final data = response.payload;

          try {
            // set SDP answer as remoteDescription for peerConnection
            await _rtcPeerConnection!.setRemoteDescription(
              RTCSessionDescription(
                data["sdp"],
                data["type"],
              ),
            );
          } catch (e) {
            print(e);
          }

          // send iceCandidate generated to remote peer over signalling
          for (RTCIceCandidate candidate in rtcIceCadidates) {
            // final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
            socket!.emit("IceCandidate", {
              "calleeId": widget.calleeId,
              "iceCandidate": {
                "id": candidate.sdpMid,
                "label": candidate.sdpMLineIndex,
                "candidate": candidate.candidate
              }
            });
          }
        }
      });

      // create SDP Offer
      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      await database.createDocument(
        databaseId: databaseId,
        collectionId: makeCallCollection,
        documentId: uniqueId,
        data: {
          "calleeId": widget.callerId,
          'sdp': offer.sdp,
          'type': offer.type,
          'call_type': 'audio_call',
          'timestamp': uniqueId,
        },
      );
      socket!.emit('makeCall', {
        "calleeId": widget.calleeId,
        "sdpOffer": offer.toMap(),
        'call_type': 'audio_call',
      });
    }
  }

  _leaveCall() {
    Navigator.pop(context);
  }

  _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Audio Call"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(children: [
                RTCVideoView(
                  _remoteRTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: SizedBox(
                    height: 150,
                    width: 120,
                    child: RTCVideoView(
                      _localRTCVideoRenderer,
                      mirror: isFrontCameraSelected,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 50.0,
                          child: Icon(
                            Icons.person,
                            size: 50,
                          ), // Replace with the caller's profile picture URL
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          widget.callName, // Replace with the caller's name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off,
                                  color: Colors.white),
                              onPressed: _toggleMic,
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.call_end, color: Colors.red),
                              onPressed: _leaveCall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 12),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       IconButton(
            //         icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
            //         onPressed: _toggleMic,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.call_end),
            //         iconSize: 30,
            //         onPressed: _leaveCall,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    super.dispose();
  }
}
