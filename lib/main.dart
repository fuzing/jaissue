import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

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
  int _counter = 0;
  AudioPlayer _player;
  // static String _urlBase = 'https://fuzing.s3.amazonaws.com/ja/sample-audio-0';

  bool _isPlaying = false;

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


  void _playLoop() async {
    if (_isPlaying)
      return;

    _player = AudioPlayer(handleInterruptions: true);


    // switch (_type) {
    //   case 'network':
    //     print('background play from network - $_uri');
    //     // see: https://github.com/ryanheise/just_audio/blob/media-source/lib/just_audio.dart#L308
    //     // await setUrl(_uri);
    //     audioSource = AudioSource.uri(Uri.parse(_uri));
    //     break;
    //   case 'asset':
    //     print('background play from asset - $_uri');
    //     // await _audioPlayer.setAsset(_uri);
    //     audioSource = AudioSource.uri(Uri.parse('asset:///$_uri'));
    //     break;
    //   case 'file':
    //     print('background play from file - $_uri');
    //     // await _audioPlayer.setFilePath(_uri);
    //     audioSource = AudioSource.uri(Uri.file(_uri));
    //     break;
    //   default:
    //     print('background play undefined - $_uri');
    //     break;
    // }


    AudioSource audioSource;
    final String assetName = '10-second-audio.m4a';

    // Ryan - this seems to work - endlessly looping
    audioSource = LoopingAudioSource(
      // child: AudioSource.uri(Uri.parse('asset:///assets/$assetName')),
      child: AudioSource.uri(Uri.parse('https://fuzing.s3.amazonaws.com/ja/$assetName')),
      count: 2,
    );

    // // copy our asset to the file system
    // final String docPath = (await getApplicationDocumentsDirectory()).path;
    // File file = File('$$docPath/10-second-audio.m4a');
    // final fileBytes = await rootBundle.load(path);
    // final buffer = fileBytes.buffer;
    // await file.writeAsBytes(
    //     buffer.asUint8List(fileBytes.offsetInBytes, fileBytes.lengthInBytes));



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
