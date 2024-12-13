import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:svg_interactive/symbol_widgets/gauges/angular.dart';
import 'package:svg_interactive/symbol_widgets/gauges/segmented.dart';
import 'package:tuple/tuple.dart';

import 'symbol_elements.dart';

final log = Logger('LoggerFiles');

enum TypeWidget { angular, linear, segmented, witness }

class SCADA {
  final String _scadatemplate;
  final double _height, _width;

  SCADA(this._scadatemplate, this._height, this._width);

  String get scadatemplate => _scadatemplate;
  double get height => _height;
  double get width => _width;

  static Future<dynamic> openFile(String filepath) async {
    var input = await File(filepath).readAsString();
    return jsonDecode(input);
  }

  static Future<Tuple2<SCADA, List<Symbol>>> initializationSCADA(
      String pathJSONSCADA) async {
    var jsonData = await openFile(pathJSONSCADA);
    SCADA mySCADA = await SCADA._initializeTemplate(jsonData["scada"]);
    List<Symbol> listWidgets =
        await SCADA._initializeWidgets(jsonData["widgets"]);

    return Tuple2<SCADA, List<Symbol>>(mySCADA, listWidgets);
  }

  static Future<SCADA> _initializeTemplate(var scadajson) async {
    var scadatemplate = await File(scadajson["path"]).readAsString();
    return SCADA(scadatemplate, scadajson["height"], scadajson["width"]);
  }

  static Future<List<Symbol>> _initializeWidgets(var listJson) async {
    List<Symbol> myAuxList = [];

    listJson.forEach((var widget_) async {
      String id = widget_["id"];

      Value<double> widgetValue = Value<double>(widget_["value"]["minimum"],
          widget_["value"]["maximum"], widget_["value"]["unit"], 0.00, 0.00);
      var myWidget = await File(widget_["path"]).readAsString();

      switch (widget_["type"]) {
        case 0:
          Needle myNeedle = Needle(
              Position(widget_["elements"][0]["position"]["y"],
                  widget_["elements"][0]["position"]["x"]),
              widget_["elements"][0]["degree"]["minimum"],
              widget_["elements"][0]["degree"]["maximum"],
              widget_["elements"][0]["degree"]["initial"]);
          Angular myAngularWidget =
              Angular(myNeedle, id, myWidget, widgetValue);
          myAuxList.add(myAngularWidget);
          break;
        case 2:
          Segmentation mySegmentationWidget = Segmentation(
              widget_["segments"],
              widget_["colours"]["active"],
              widget_["colours"]["inactive"],
              id,
              widgetValue,
              myWidget);
          myAuxList.add(mySegmentationWidget);
          break;
      }
    });
    return myAuxList;
  }
}

class Symbol {
  final String _idSymbol;

  Symbol(this._idSymbol);

  String refreshGauge() {
    return "</g>";
  }

  String get idSymbol => _idSymbol;
}

class Gauge extends Symbol {
  Value<double> myvalue;
  final String? _scadawidget;

  Gauge(this._scadawidget, this.myvalue, String inIDSymbol) : super(inIDSymbol);

  String? get scadaWidget => _scadawidget;

  void setMyValue(newValue) => myvalue = newValue;
}
