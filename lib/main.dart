import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  static String assetName = '10-second-audio.m4a';
  static String bucketUrl = 'https://fuzing.s3.amazonaws.com/ja';

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

  void _playLoop() async {
    if (_isPlaying)
      return;

    await _copyAssetToFileSystem();

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

    String _docDir = (await getApplicationDocumentsDirectory()).path;

    // Ryan - this seems to work - endlessly looping
    audioSource = LoopingAudioSource(
      // child: AudioSource.uri(Uri.parse('asset:///assets/$assetName')),
      // child: AudioSource.uri(Uri.parse('$bucketUrl/$assetName')),
      child: AudioSource.uri(Uri.file('$_docDir/$assetName')),
      count: 2,
    );

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























import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


void main() {

  runApp(MyApp());


  // constrain the image size
  imageCache.maximumSize = 10;
  // PaintingBinding.instance.imageCache.maximumSize = 10;

  Timer.periodic(Duration(seconds: 15), (timer) {
    // print("------ clearing image cache --------");
    // imageCache.clear();
    // imageCache.clearLiveImages();
    // PaintingBinding.instance.imageCache.clear();
    // PaintingBinding.instance.imageCache.clearLiveImages();
    print("--------------- image cache size (${imageCache.currentSize}, ${imageCache.currentSizeBytes}, ${imageCache.liveImageCount}");
    print("--------------- PaintingBinding image cache size (${PaintingBinding.instance.imageCache.currentSize}, ${PaintingBinding.instance.imageCache.currentSizeBytes}, ${PaintingBinding.instance.imageCache.liveImageCount}");
  });

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



// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// const int numberOfImages = 1000;

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   bool _imagesReady = false;
//   Image _image;
//   String _imagesDir;



//   // make numerous copies of an image from our bundle, to local storage
//   Future<void> replicateImageManyTimesToStorage() async {
//     _imagesDir = (await getApplicationDocumentsDirectory()).path;

//     ByteData data = await rootBundle.load("assets/rectangle.jpg");
//     List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

//     for (int i = 0; i < numberOfImages; ++i) {
//       await File("$_imagesDir/$i.jpg").writeAsBytes(bytes);
//     }

//     print("Images ready");
//     _imagesReady = true;
//   }

//   @override initState() {
//     super.initState();
//     replicateImageManyTimesToStorage();
//     Timer.periodic(Duration(milliseconds: 1000), (_) {
//       if (_imagesReady) {
//         setState(() {
//           // _image = Image.asset("assets/rectangle.jpg");
//           _image = Image.file(File("$_imagesDir/${_counter%numberOfImages}.jpg"));
//           _counter++;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Image has been displayed this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             Container(
//               width: 200,
//               height: 200,
//               child: _image,      // will be null until setstate called
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const int numberOfImages = 200;

class _MyHomePageState extends State<MyHomePage> {
  bool _imagesReady = false;
  String _imagesDir;


  // make numerous copies of an image from our bundle, to local storage
  Future<void> replicateImageManyTimesToStorage() async {
    _imagesDir = (await getApplicationDocumentsDirectory()).path;

    ByteData dataBlue = await rootBundle.load("assets/rectangle-blue.jpg");
    List<int> bytesBlue = dataBlue.buffer.asUint8List(dataBlue.offsetInBytes, dataBlue.lengthInBytes);
    ByteData dataGray = await rootBundle.load("assets/rectangle-gray.jpg");
    List<int> bytesGray = dataGray.buffer.asUint8List(dataGray.offsetInBytes, dataGray.lengthInBytes);

    for (int i = 0; i < numberOfImages; ++i) {
      String pathName = "$_imagesDir/$i.jpg";
      // if (await File(pathName).exists())
      //   await File(pathName).delete();

      if (!await File(pathName).exists())
        await File(pathName).writeAsBytes(i %2 == 0 ? bytesBlue : bytesGray);
    }

    print("Images ready");
    setState(() => _imagesReady = true);
  }

  @override initState() {
    super.initState();
    replicateImageManyTimesToStorage();
  }

  Widget buildCrashIOS(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'Image has been displayed this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            Expanded(
              child: !_imagesReady ? Text("Preparing") : GridView.builder(
                cacheExtent: 0,
                padding: const EdgeInsets.all(4.0),     // padding for the whole grid - not individual cards
                itemCount: numberOfImages,
                // itemCount: _filteredMediaModels.length * 4,
                itemBuilder: (ctx, i) {
                  return Image.file(File("$_imagesDir/$i.jpg"));
                },
                // scrollDirection: Axis.horizontal,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildNoCrash(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: 
            !_imagesReady ? Text("Preparing") : GridView.builder(
              cacheExtent: 0,
              padding: const EdgeInsets.all(4.0),     // padding for the whole grid - not individual cards
              itemCount: numberOfImages,
              itemBuilder: (ctx, i) {
                return Image.file(
                  File("$_imagesDir/$i.jpg"),
                  // cacheHeight: 400,
                  // cacheWidth: 400,
                );
              },
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
            ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // return buildNoCrash(context);
    return buildCrashIOS(context);
  }


}



