import 'dart:core';
import "dart:math";
import 'package:logging/logging.dart';

import '../symbol_widget.dart';
import '../symbol_elements.dart';

class Angular extends Gauge {
  final Needle _myNeedle;

  Angular(this._myNeedle, String inIDSymbol, String inWidgetSCADA,
      Value<double> inMyValue)
      : super(inWidgetSCADA, inMyValue, inIDSymbol);

  @override
  String refreshGauge() {
    try {
      if (scadaWidget == null) {
        throw Exception("File not Found!");
      }
      Random random = Random();
      myvalue.setActual(random.nextInt(myvalue.maximum.toInt()).toDouble());
      String auxSVG = scadaWidget!.replaceAll(
          '{${idSymbol}_degree}', // Regular expression for <tspan>
          _myNeedle.actualDegree(myvalue.actual, myvalue.maximum).toString());
      auxSVG = _myNeedle.setPositionInWidget(auxSVG);

      return auxSVG;
    } catch (e) {
      Logger.root.level = Level.SEVERE;
      log.shout(e);
    }
    return "</g>";
  }
}

class Needle {
  final String _id = "needle";
  final Position _needlePosition;
  final double _minimum, _maximum, _initial;

  Needle(this._needlePosition, this._minimum, this._maximum, this._initial);

  String get id => _id;
  Position get myPosition => _needlePosition;
  double get minimumDegree => _minimum;
  double get maximumDegree => _maximum;
  double get initialDegree => _initial;

  double actualDegree(double inValue, double maximumValue) =>
      _initial +
      (inValue * ((_minimum).abs() + (_maximum.abs()) / maximumValue));

  String setPositionInWidget(String myWidget) {
    String auxWidget = myWidget
        .replaceAll('{needle_position_x}', _needlePosition.positionX.toString())
        .replaceAll(
            '{needle_position_y}', _needlePosition.positionY.toString());
    return auxWidget;
  }
}
