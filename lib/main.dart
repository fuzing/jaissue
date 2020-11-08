import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:flutter/services.dart';
// import 'dart:async';


enum AccessType {
  Asset,
  Network,
  File
}


// Ryan - toggling makeItFail will select one of two files
//    The larger file (just check what makeItFail does) fails.  The smaller one does not.  This is not a peculiarity with the file (I have many other samples that fail).
const bool makeItFail = false;                         // true selects larger file, false selects smaller file
const AccessType accessType = AccessType.Asset;       // where do you want the player to play from (see enum above)
const bool composeLoopingAudioSource = false;         // you'll see in the code that we can add the additional step of composing a LoopingAudioSource  (makes no difference either way)
                                                      // My use case requires the use of LoopingAudioSource due to "non-gapless" IOS issue.


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

  // ./assets/ocean-waves.m4a - approx 800KB
  // ./assets/10-second-audio.m4a - approx 100KB
  static String assetName = makeItFail ? 'ocean-waves.m4a' : '10-second-audio.m4a';

  static String bucketUrl = 'https://fuzing.s3.amazonaws.com/ja';

  int _counter = 0;
  AudioPlayer _player;
  bool _isPlaying = false;


  // static String _urlBase = 'https://fuzing.s3.amazonaws.com/ja/sample-audio-0';


  // void _playNext() async {
  //   _player?.dispose();
  //   _player = AudioPlayer(handleInterruptions: true);
  //   String fullUrl = '$_urlBase$_counter.m4a';
  //   print("Loading $fullUrl");
  //   await _player.load(AudioSource.uri(Uri.parse(fullUrl)));
  //   _player.play();

  //   // trigger refresh
  //   setState(() {
  //     _counter = ++_counter % 10;
  //   });
  // }


  //
  // copy the audio file to the file system so we have an "asset" version, and filesystem version.
  //    I also hosted a network version that you can check
  //
  Future<void> _copyAssetToFileSystem() async {
    String _docDir = (await getApplicationDocumentsDirectory()).path;
    String pathName = "$_docDir/$assetName";

    // maybe we already did this in a previous run
    if (await File(pathName).exists())
      return;

    ByteData data = await rootBundle.load("assets/$assetName");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(pathName).writeAsBytes(bytes);
  }



  //
  // this is where the action is
  //
  void _playLoop() async {
    if (_isPlaying)
      return;

    await _copyAssetToFileSystem();

    _player = AudioPlayer(handleInterruptions: true);

    AudioSource audioSource;
    String _docDir = (await getApplicationDocumentsDirectory()).path;

    switch (accessType) {
      case AccessType.Asset:
        print("Playing Asset $assetName");
        audioSource = AudioSource.uri(Uri.parse('asset:///assets/$assetName'));
        break;
      case AccessType.File:
        print("Playing File $assetName");
        audioSource = AudioSource.uri(Uri.parse('$_docDir/$assetName'));
        break;
      case AccessType.Network:
        print("Playing Network $assetName");
        audioSource = AudioSource.uri(Uri.parse('$bucketUrl/$assetName'));
        break;
    }

    if (composeLoopingAudioSource) {
      audioSource = LoopingAudioSource(
        child: audioSource,
        count: 2,
      );

    }

    await _player.setLoopMode(LoopMode.all);
    await _player.load(audioSource);
    _player.play();

    setState(() => _isPlaying = true);
  }


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
        // onPressed: _playNext,
        onPressed: _playLoop,
        tooltip: 'Play Next',
        child: Icon(Icons.add),
      ),
    );
  }
}




