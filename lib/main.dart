import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  Timer _timer;
  String _cycleText = '0';
  int _length = 15;
  List<List<bool>> _cellArray;
  Icon _floatButtonIcon = Icon(Icons.play_arrow);

  @override
  void initState() {
    super.initState();
    // _setTimer();

    _cellArray = List<List<bool>>.generate(
      _length,
      (i) => List<bool>.generate(_length, (j) => false).toList(),
    ).toList();
  }

  void _setTimer() {
    _timer = Timer.periodic(
        Duration(milliseconds: 300), (timer) => _nextLifeCycle());
  }

  void _nextLifeCycle() {
    setState(
      () => _cycleText = _timer.tick.toString(),
    );
    var tmpArray = List<List<bool>>(_length);
    for (int i = 0; i < _length; i++) {
      tmpArray[i] = List<bool>.generate(_length, (idx) => false).toList();
    }

    for (int i = 0; i < _length; i++) {
      for (int j = 0; j < _length; j++) {
        bool isAlive = _cellArray[i][j];
        int aliveCellCount = 0;
        for (int hidx = i - 1; hidx <= i + 1; hidx++) {
          if (hidx < 0)
            continue;
          else if (hidx >= _length) break;

          for (int widx = j - 1; widx <= j + 1; widx++) {
            if (widx < 0 || (hidx == i && widx == j))
              continue;
            else if (widx >= _length) break;

            if (_cellArray[hidx][widx]) aliveCellCount++;
          }
        }
        // 誕生: 死んでいるセルに隣接する生きたセルがちょうど3つあれば、次の世代が誕生
        if (!isAlive) {
          if (aliveCellCount == 3) tmpArray[i][j] = true;
        } else {
          // 生存: 生きているセルに隣接する生きたセルが2つか3つならば、次の世代でも生存する
          if (aliveCellCount == 2 || aliveCellCount == 3)
            tmpArray[i][j] = true;
          // 過疎: 生きているセルに隣接する生きたセルが1つ以下ならば、過疎により死滅する
          else if (aliveCellCount <= 1)
            tmpArray[i][j] = false;
          // 過密: 生きているセルに隣接する生きたセルが4つ以上ならば、過密により死滅する
          else if (aliveCellCount >= 4) tmpArray[i][j] = false;
        }
      }
    }
    setState(() {
      _cellArray = tmpArray;
    });
  }

  void _changeTimerState() {
    if (_timer != null && _timer.isActive) {
      setState(
        () {
          _floatButtonIcon = Icon(Icons.play_arrow);
          _cycleText = '0';
        },
      );
      _timer.cancel();
    } else {
      setState(() => _floatButtonIcon = Icon(Icons.pause));
      _setTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[DrawerHeader(child: Text('fu'))],
      )),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Life Game',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'cycle: $_cycleText',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(
              width: _length * 30.0,
              height: _length * 30.0,
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: List<TableRow>.generate(
                  _length,
                  (i) => TableRow(
                    children: List<Widget>.generate(
                      _length,
                      (widgetIndex) => GestureDetector(
                        child: Container(
                          color: _cellArray[i][widgetIndex]
                              ? Colors.lightGreenAccent
                              : Colors.white,
                          height: 30,
                        ),
                        // タップされた時、2次元配列の対応するindexにbool値を反転させる
                        onTap: () => setState(() => _cellArray[i][widgetIndex] =
                            !_cellArray[i][widgetIndex]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              color: Colors.blue,
              child: Text('クリア'),
              onPressed: _clearCells,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeTimerState,
        tooltip: 'Increment',
        // child: Icon(Icons.add),
        child: _floatButtonIcon,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _clearCells() {
    setState(
      () {
        for (int i = 0; i < _cellArray.length; i++) {
          for (int j = 0; j < _cellArray[i].length; j++) {
            _cellArray[i][j] = false;
          }
        }
      },
    );
  }
}
