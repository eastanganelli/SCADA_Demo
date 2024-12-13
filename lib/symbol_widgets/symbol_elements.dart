class Position {
  final double positionX, positionY;

  Position(this.positionY, this.positionX);
}

class Value<F> {
  final F minimum, maximum;
  final String _unit;
  F _actual, _last;

  Value(this.minimum, this.maximum, this._unit, this._actual, this._last);

  F get actual => this._actual;
  F get last => this._last;
  String get unit => this._unit;

  void setActual(F newValue) {
    this._last = this._actual;
    this._actual = newValue;
  }
}
