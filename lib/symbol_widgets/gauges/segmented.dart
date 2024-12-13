import 'dart:core';
import "dart:math";
import 'package:logging/logging.dart';

import '../symbol_widget.dart';
import '../symbol_elements.dart';

class Segmentation extends Gauge {
  final String _activeColour, _inactiveColour;
  final int _countedSegments;

  Segmentation(this._countedSegments, this._activeColour, this._inactiveColour,
      String inIDSymbol, Value<double> inMyValue, String inWidgetSCADA)
      : super(inWidgetSCADA, inMyValue, inIDSymbol);

  int _actualLevel(inValue) =>
      (inValue / (myvalue.maximum / _countedSegments)).toInt();

  @override
  String refreshGauge() {
    try {
      if (scadaWidget == null) {
        throw Exception("File not Found!");
      }
      Random random = Random();
      myvalue.setActual(random.nextInt(myvalue.maximum.toInt()).toDouble());
      int maxPosition = _actualLevel(myvalue.actual);
      String auxSVG = scadaWidget!;
      for (int i = 1; i <= _countedSegments; i++) {
        String idReplace = '{${idSymbol}_${i.toString()}}';
        auxSVG = auxSVG.replaceAll(
            idReplace, (i <= maxPosition ? _activeColour : _inactiveColour));
      }
      //ValueLast = ValueActual;
      return auxSVG;
    } catch (e) {
      Logger.root.level = Level.SEVERE;
      log.shout(e);
    }
    return "</g>";
  }
}
