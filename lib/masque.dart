class Masque {
  static final Masque _masque = new Masque._internal();

  String text;
  factory Masque() {
    return _masque;
  }
  Masque._internal();
}

final appData = Masque();
