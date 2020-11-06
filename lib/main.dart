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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    await _player.play();

    // trigger refresh
    setState(() {
      _counter = (_counter + 1) % 10;
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
