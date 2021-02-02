import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';
// import 'dart:async';


enum AccessType {
  Asset,
  Network,
  File
}


// Ryan - toggling makeItFail will select one of two files
//    The larger file (just check what makeItFail does) fails.  The smaller one does not.  This is not a peculiarity with the file (I have many other samples that fail).
const bool makeItFail = true;                         // true selects larger file, false selects smaller file
const AccessType accessType = AccessType.Asset;       // where do you want the player to play from (see enum above)
const bool composeLoopingAudioSource = false;         // you'll see in the code that we can add the additional step of composing a LoopingAudioSource  (makes no difference either way)
                                                      // My use case requires the use of LoopingAudioSource due to "non-gapless" IOS issue.
const bool loopAudioSource = true;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<ProcessingState> _processingStateSubscription;
  StreamSubscription<Duration> _positionSubscription;
  StreamSubscription<Duration> _durationSubscription;



  static String bucketUrl = 'https://fuzing.s3.amazonaws.com/ja';
  static String fileNameBase = 'sample-audio-0';

  int _counter = 0;
  AudioPlayer _player;
  bool _isPlaying = false;

  List<AudioPlayer> _playersList = [];


  void _play5() async {

    if (_playersList.length != 0) {
      for (final player in _playersList)
        player.dispose();
      _playersList = [];
    }

    // start 5 players with 1s delay in between each player
    try {
      for (int i = 0; i < 5; ++i) {
        print("Starting player ${i+1}");
        AudioPlayer player = AudioPlayer(handleInterruptions: true);
        AudioSource audioSource = AudioSource.uri(Uri.parse("asset:///assets/short-loop.m4a"));
        await player.setAudioSource(audioSource);
        await player.setLoopMode(LoopMode.one);
        player.play();
        _playersList.add(player);
        await Future.delayed(Duration(milliseconds: 1000));
      }
    }
    catch (e) {
      print(e);
    }

    // trigger refresh
    setState(() {
      _counter = ++_counter % 10;
    });
  }



  // void _playNext() async {
  //   if (_player != null) {

  //     try {
  //       await _player.pause();
  //     }
  //     catch (e) {
  //       print("player dispose _audioPlayer.pause() caught $e");
  //     }

  //     //
  //     // Note/Warning - calling stop under certain circumstances (such as after background file has been removed from the filesystem) never returns
  //     // await _audioPlayer.stop();
  //     //

  //     try {
  //       await _processingStateSubscription.cancel();
  //     }
  //     catch (e) {
  //       print("problem canceling _processingStateSubscription is $e");
  //     }

  //     try {
  //       await _positionSubscription.cancel();
  //     }
  //     catch (e) {
  //       print("problem canceling _positionSubscription is $e");
  //     }

  //     try {
  //       await _durationSubscription.cancel();
  //     }
  //     catch (e) {
  //       print("problem canceling _durationSubscription is $e");
  //     }

  //     try {
  //       await _player.dispose();
  //     }
  //     catch (e) {
  //       print("_audioPlayer.dispose() threw exception $e");
  //     }

  //   }
  //     // _player?.dispose();

  //   _player = AudioPlayer(handleInterruptions: true);



  // _positionSubscription = _player.createPositionStream(
  //     minPeriod: Duration(milliseconds: 500),
  //     maxPeriod: Duration(milliseconds: 500),
  //   ).listen((Duration position) async {});
  //   _durationSubscription = _player.durationStream.distinct().listen((Duration duration) async {});
  //   _processingStateSubscription = _player.processingStateStream.listen((state) {});

  //   String fullUrl = '$bucketUrl/$fileNameBase$_counter.m4a';
  //   print("Loading $fullUrl");
  //   await _player.setAudioSource(AudioSource.uri(Uri.parse(fullUrl)));

  //   if (loopAudioSource)
  //     await _player.setLoopMode(LoopMode.all);

  //   _player.play();

  //   // trigger refresh
  //   setState(() {
  //     _counter = ++_counter % 10;
  //   });
  // }


  // //
  // // copy the audio file to the file system so we have an "asset" version, and filesystem version.
  // //    I also hosted a network version that you can check
  // //
  // Future<void> _copyAssetToFileSystem(String assetName) async {
  //   String _docDir = (await getApplicationDocumentsDirectory()).path;
  //   String pathName = "$_docDir/$assetName";

  //   // maybe we already did this in a previous run
  //   if (await File(pathName).exists())
  //     return;

  //   ByteData data = await rootBundle.load("assets/$assetName");
  //   List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  //   await File(pathName).writeAsBytes(bytes);
  // }

  // //
  // // copy an audio file from the network to the file system so we have an "network" version, and filesystem version.
  // //
  // Future<void> _copyNetworkToFileSystem(String fileName) async {
  //   String _docDir = (await getApplicationDocumentsDirectory()).path;
  //   String pathName = "$_docDir/$fileName";

  //   // maybe we already did this in a previous run
  //   if (await File(pathName).exists())
  //     return;


  //   final request = http.Request('GET', Uri.parse('$bucketUrl/$fileName'));
  //   final http.StreamedResponse response = await http.Client().send(request);
  //   if (response.statusCode >= 300)
  //     throw "Error";

  //   await response.stream.pipe(File('$_docDir/$fileName').openWrite());

  //   print("Finished writing to local file");


  //   // ByteData data = await rootBundle.load("assets/$assetName");
  //   // List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  //   // await File(pathName).writeAsBytes(bytes);
  // }


  // //
  // // this is where the action is
  // //
  // void _playLoop() async {
  //   if (_isPlaying)
  //     return;

  //   await _copyAssetToFileSystem();

  //   _player = AudioPlayer(handleInterruptions: true);

  //   AudioSource audioSource;
  //   String _docDir = (await getApplicationDocumentsDirectory()).path;

  //   switch (accessType) {
  //     case AccessType.Asset:
  //       print("Playing Asset $assetName");
  //       audioSource = AudioSource.uri(Uri.parse('asset:///assets/$assetName'));
  //       break;
  //     case AccessType.File:
  //       print("Playing File $assetName");
  //       audioSource = AudioSource.uri(Uri.parse('$_docDir/$assetName'));
  //       break;
  //     case AccessType.Network:
  //       print("Playing Network $assetName");
  //       audioSource = AudioSource.uri(Uri.parse('$bucketUrl/$assetName'));
  //       break;
  //   }

  //   if (composeLoopingAudioSource) {
  //     audioSource = LoopingAudioSource(
  //       child: audioSource,
  //       count: 2,
  //     );
  //   }

  //   print("This version should ${makeItFail ? '' : 'not '}fail");

  //   if (loopAudioSource)
  //     await _player.setLoopMode(LoopMode.all);

  //   await _player.setAudioSource(audioSource);
  //   _player.play();

  //   setState(() => _isPlaying = true);
  // }


  Future<void> _initSession() async {
    (await AudioSession.instance).configure(AudioSessionConfiguration.music());
  }

  @override
  initState() {
    super.initState();
    _initSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Playing is ${_player != null ? 'yes' : 'no'}',
            ),
            if (_player != null)
              Text(
                'Playing track $_counter',
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _play5,
        // onPressed: _playNext,
        // onPressed: _playLoop,
        tooltip: 'Play Next',
        child: Icon(Icons.add),
      ),
    );
  }
}




