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
  static String _urlBase = 'https://fuzing.s3.amazonaws.com/ja/sample-audio-0';

  void _playNext() async {
    _player?.dispose();
    _player = AudioPlayer(handleInterruptions: true);
    String fullUrl = '$_urlBase$_counter.m4a';
    print("Loading $fullUrl");
    await _player.load(AudioSource.uri(Uri.parse(fullUrl)));
    _player.play();

    // trigger refresh
    setState(() {
      _counter = ++_counter % 10;
    });
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
        onPressed: _playNext,
        tooltip: 'Play Next',
        child: Icon(Icons.add),
      ),
    );
  }
}
