import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;
import 'soura.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Coran Phonétique'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List suraList = [];

  @override
  void initState() {
    super.initState();
    loadSuraList();
  }

  loadSuraList() async {
    final temporaryList = [];

    // final xmlFile = new File('raw/suras.xml');
    // final sura = xml.XmlDocument.parse(xmlFile.readAsStringSync());

    String textasset = "assets/raw/suras.xml"; //path to text file asset
    String text = await rootBundle.loadString(textasset);

    final document = xml.XmlDocument.parse(text);
    //print(sura.toString());

    final suraNode = document.findElements('quran').first;
    final suras = suraNode.findElements('sura');
    // loop through the document and extract values
    for (final sura in suras) {
      final id = sura.findElements('id').first.text;
      final chapter = sura.findElements('chapter').first.text;
      final verse = sura.findElements('verse').first.text;
      final duration = sura.findElements('duration').first.text;
      temporaryList.add(
          {'id': id, 'chapter': chapter, 'verse': verse, 'duration': duration});
    }

    // Update the UI
    setState(() {
      suraList = temporaryList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: suraList.length,
          itemBuilder: (context, index) => InkWell(
            key: ValueKey(suraList[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SouraPage(suraList[index]['chapter'],
                      suraList[index]['verse'], suraList[index]['id']),
                ),
              );
            },
            child: Card(
              margin:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 1, top: 1),
              color: Colors.white,
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      leading: Text(
                        suraList[index]['id'],
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
                        suraList[index]['chapter'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${suraList[index]['verse']} versets'))
                ],
              ),
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
