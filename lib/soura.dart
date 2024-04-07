import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

final player = AudioPlayer();

/* class SouraPage extends StatelessWidget {
  final String _title;
  final String _subTitle;
  final String _id;

  SouraPage(this._title, this._subTitle, this._id);

  @override
  Widget build(BuildContext context) {
    return SouraSection(_title, _subTitle, _id);

    /* Scaffold(
      appBar: MyAppBar(_title, _subTitle, _id),
      body:
          /*Center(
        child:  Column(
          children: [ */
          SouraSection(_id),
      /* ],
        ), */
      // ),
      
    ); */
  }
} */

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;
  final String _subTitle;
  final String _id;

  MyAppBar(this._title, this._subTitle, this._id);

  Size get preferredSize => new Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,

        //centerTitle: true,
        backgroundColor: Colors.white10,
        //backgroundColor: Colors.grey[300],

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () {
            player.stop();
            Navigator.pop(context);
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_id}. ${_title}',
              style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${_subTitle} versets',
              style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(

              // add icon, by default "3 dot" icon
              icon: Icon(Icons.more_vert, color: Colors.blue, size: 40),
              itemBuilder: (context) {
                return [
                  /*  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Répéter le verset"),
                          Checkbox(
                            //checkColor: Colors.white,
                            //fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: true,
                            onChanged: (bool? value) {
                              /*  setState(() {
          isChecked = value!;
        }); */
                            },
                          ),
                        ]),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lire tout"),
                          Checkbox(
                            //checkColor: Colors.white,
                            //fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: true,
                            onChanged: (bool? value) {
                              /*  setState(() {
          isChecked = value!;
        }); */
                            },
                          ),
                        ]),
                  ), */
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tout télécharger"),
                          SizedBox(
                            width: 16,
                          ),
                          Icon(
                            Icons.download,
                            color: Colors.blue,
                            size: 30,
                          ),
                          SizedBox(
                            width: 0,
                          )
                        ]),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  print("My account menu is selected.");
                } else if (value == 1) {
                  print("Settings menu is selected.");
                } else if (value == 2) {
                  print("Logout menu is selected.");
                }
              }),
        ]);
  }
}

class SouraPage extends StatefulWidget {
  final String _id;
  final String _title;
  final String _subTitle;

  //SouraSection({Key? key}) : super(key: key);
  SouraPage(this._title, this._subTitle, this._id);

  @override
  _SouraPageState createState() =>
      _SouraPageState(this._title, this._subTitle, this._id);
}

class _SouraPageState extends State<SouraPage> {
  final String _id;
  final String _title;
  final String _subTitle;

  List<String> verseList = [];
  List<String> verseListFr = [];

  int tapped = -1;
  //final player = AudioPlayer();

  Source? source;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  int repeated = -1;

  // double _currentSliderValue = 0;

  _SouraPageState(this._title, this._subTitle, this._id);

  final paymentListKey = GlobalKey<_SouraPageState>();

  String audioName = "";
  String pt1 = "";
  String pt2 = "";
  int global_index = -1;

  String getPt1() {
    String s = "";
    if (int.parse(_id) < 10) {
      s = "v00${_id}";
    } else if (int.parse(_id) < 100) {
      s = "v0${_id}";
    } else {
      s = "v${_id}";
    }

    return s;
  }

  @override
  void initState() {
    super.initState();
    loadSoura(_id);
    /*  _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        ); */

    _initStreams();
    pt1 = getPt1();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.completed;
        _position = Duration.zero;
        player.seek(_position!);
      });

      if (repeated == 0) {
        //print("play again");
        player.play(source!);
        setState(() {
          _playerState = PlayerState.playing;
        });
      }

      if (repeated == 1) {
        if (global_index != int.parse(_subTitle)) {
          global_index = global_index + 1;
          if (global_index < 10) {
            pt2 = "00${global_index.toString()}";
          } else if (global_index < 100) {
            pt2 = "0${global_index.toString()}";
          } else {
            pt2 = "${global_index.toString()}";
          }

          audioName = "${pt1}${pt2}.mp3";

          setState(() {
            source = AssetSource('audios/${audioName}');
            tapped = global_index;
            _playerState = PlayerState.playing;
          });

          player.play(source!);
        }
      }
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  /* Future<File> writeToFile(ByteData data, String path) {
    return File(path).writeAsBytes(data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    ));
  } */

  loadSoura(String _id) async {
    final textasset = "assets/raw/s${_id}.txt"; //path to text file asset
    String text = await rootBundle.loadString(textasset);
    //final textFile = File(text);
    List<String> lines = text.split("\n");

    final textassetfr = "assets/raw/s${_id}_fr.txt"; //path to text file asset
    String textfr = await rootBundle.loadString(textassetfr);

    List<String> linesfr = textfr.split("\n");

    setState(() {
      verseList = lines;
      verseListFr = linesfr;
    });

    // print('ok ${text.length}');

    //print(_id);

    /*  for (var l in lines) {
      print(l);
    } */

    /* final directory = (await getTemporaryDirectory()).path;
    final file = await writeToFile(text, '$directory/sura.txt');
    List<String> lines = await file.readAsLines();

    for (var l in lines) {
      print(l);
    } */
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        player.stop();
        return true;
      },
      child: Scaffold(
        appBar: MyAppBar(_title, _subTitle, _id),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_id != "1" && _id != "9") ...[
                InkWell(
                  onTap: () async {
                    if (tapped != -1) {
                      await player.stop();
                    }

                    audioName = "v001001.mp3";
                    global_index = 0;

                    setState(() {
                      source = AssetSource('audios/${audioName}');
                      tapped = 0;
                      _playerState = PlayerState.playing;
                    });

                    await player.play(source!);

                    /*  player.onPlayerComplete.listen((event) {
                    setState(() {
                      _playerState = PlayerState.stopped;
                    });
                  }); */
                  },
                  child: Card(
                    margin:
                        EdgeInsets.only(left: 8, right: 8, bottom: 1, top: 1),
                    color: Colors.white,
                    elevation: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Text(
                            "",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          title: Text(
                            "Bismi Allahi alrrahmani alrraheemi",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: tapped == 0 ? Colors.blue : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                              "Au nom d’Allah, le Tout Miséricordieux, le Très Miséricordieux."),
                        )
                      ],
                    ),
                  ),
                )
              ],
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: verseList.length,
                itemBuilder: (context, index) => InkWell(
                  key: ValueKey(verseList[index]),
                  onTap: () async {
                    if (tapped != -1) {
                      await player.stop();
                    }

                    /* String audioName = "";
                  String pt1 = "";
                  String pt2 = ""; */

                    /*  if (int.parse(_id) < 10) {
                    pt1 = "v00${_id}";
                  } else if (int.parse(_id) < 100) {
                    pt1 = "v0${_id}";
                  } else {
                    pt1 = "v${_id}";
                  } */

                    global_index = index + 1;

                    if (global_index < 10) {
                      pt2 = "00${global_index.toString()}";
                    } else if (global_index < 100) {
                      pt2 = "0${global_index.toString()}";
                    } else {
                      pt2 = "${global_index.toString()}";
                    }

                    audioName = "${pt1}${pt2}.mp3";

                    setState(() {
                      source = AssetSource('audios/${audioName}');
                      tapped = global_index;
                      _playerState = PlayerState.playing;
                    });

                    await player.play(source!);

                    /*  player.onPlayerComplete.listen((event) {
                    setState(() {
                      _playerState = PlayerState.stopped;
                    });
                  }); */
                  },
                  child: Card(
                    margin: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 1, top: 1),
                    color: Colors.white,
                    elevation: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )
                            /*  Icon(
                        Icons.car_repair,
                        color: Colors.red,
                        size: 25,
                      ) */
                            ,
                            title: Text(
                              verseList[index],
                              style: TextStyle(
                                color: tapped == (index + 1)
                                    ? Colors.blue
                                    : Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(verseListFr[index])),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                onChanged: (v) {
                  final duration = _duration;
                  if (duration == null) {
                    return;
                  }
                  final position = v * duration.inMilliseconds;
                  player.seek(Duration(milliseconds: position.round()));

                  if (_playerState == PlayerState.completed) {
                    setState(() {
                      //_currentSliderValue = position;
                      _position = Duration(milliseconds: position.round());
                    });
                  }
                },
                value: (_position != null &&
                        _duration != null &&
                        _position!.inMilliseconds > 0 &&
                        _position!.inMilliseconds < _duration!.inMilliseconds)
                    ? _position!.inMilliseconds / _duration!.inMilliseconds
                    : 0.0,
              ),
              /*  Text(
              _position != null
                  ? '$_positionText / $_durationText'
                  : _duration != null
                      ? _durationText
                      : '',
              style: const TextStyle(fontSize: 15.0),
            ), */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _position != null
                        ? '$_positionText / $_durationText'
                        : _duration != null
                            ? _durationText
                            : '0:00:00 / 0:00:00',
                    style: const TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    key: const Key('play_button'),
                    onPressed: () async {
                      // print(_playerState);
                      //   print(tapped);
                      //print(source);
                      if (source != null) {
                        // print(_playerState);

                        if (_playerState == PlayerState.completed) {
                          await player.play(source!);

                          setState(() {
                            _playerState = PlayerState.playing;
                          });

                          /* player.onPlayerComplete.listen((event) {
                      setState(() {
                        _playerState = PlayerState.completed;
                      });
                    }); */

                          return;
                        }

                        if (_playerState == PlayerState.playing) {
                          await player.pause();
                          // print('OK');

                          setState(() {
                            _playerState = PlayerState.paused;
                          });

                          return;
                        }

                        if (_playerState == PlayerState.paused) {
                          await player.resume();

                          setState(() {
                            _playerState = PlayerState.playing;
                          });

                          /* player.onPlayerComplete.listen((event) {
                      setState(() {
                        _playerState = PlayerState.completed;
                      });
                    }); */

                          return;
                        }
                      } else {
                        // print(source);
                        Fluttertoast.showToast(
                            msg: "Veuillez cliquer sur un verset",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            // backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    iconSize: 45.0,
                    icon: _playerState == PlayerState.playing
                        ? const Icon(Icons.pause_circle_filled_rounded)
                        : const Icon(Icons.play_circle_fill_rounded),
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    icon: repeated == -1
                        ? const Icon(
                            Icons.repeat_on_sharp,
                            color: Colors.grey,
                          )
                        : repeated == 0
                            ? const Icon(
                                Icons.repeat_one_on_sharp,
                                color: Colors.blue,
                              )
                            : const Icon(
                                Icons.repeat_on_sharp,
                                color: Colors.blue,
                              ),
                    onPressed: () {
                      if (repeated == -1) {
                        setState(() {
                          repeated = 0;
                        });

                        Fluttertoast.showToast(
                            msg: "Le verset sera répété en boucle",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            // backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        return;
                      }
                      if (repeated == 0) {
                        setState(() {
                          repeated = 1;
                        });

                        Fluttertoast.showToast(
                            msg: "La sourate sera répétée en boucle",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            // backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        return;
                      }
                      if (repeated == 1) {
                        setState(() {
                          repeated = -1;
                        });

                        Fluttertoast.showToast(
                            msg: "Boucle désactivée",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            // backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        return;
                      }
                    },
                  ),
                  SizedBox(
                    width: 57,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
