//import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:window_size/window_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:svg_interactive/symbol_widgets/symbol_widget.dart';

import './symbol_widgets/symbol_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    //setWindowMinSize(const Size(1280, 720));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScadaScreen(),
    );
  }
}

class ScadaScreen extends StatefulWidget {
  const ScadaScreen({super.key});
  @override
  State<ScadaScreen> createState() => _ScadaScreenState();
}

class _ScadaScreenState extends State<ScadaScreen> {
  String _svgString = '<svg></svg>',
      updatedSvg = '<svg width="1920px" height="1080px">...</svg>';
  Timer? _timer;
  List<Symbol> mySensors = [];

  Future<void> _loadscada() async {
    var auxResult =
        await SCADA.initializationSCADA('assets/SCADA_Assets/scada.json');
    _svgString = auxResult.item1.scadatemplate;
    updatedSvg = auxResult.item1.scadatemplate;
    mySensors = auxResult.item2;
  }

  @override
  void initState() {
    _loadscada();
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      print('Counted elements in array ${mySensors.length}');
      updatedSvg = _svgString;
      mySensors.forEach((element) {
        print('Element with ID {${element.idSymbol}}');
        updatedSvg = updatedSvg.replaceAll(
            '{${element.idSymbol}}', element.refreshGauge());
      });
      setState(() {});
    });

    return Scaffold(
      appBar: AppBar(title: const Text("SCADA Monitor")),
      body: Container(
        child: InteractiveViewer(
          child: SvgPicture.string(updatedSvg),
        ),
      ),
    );
  }
}
