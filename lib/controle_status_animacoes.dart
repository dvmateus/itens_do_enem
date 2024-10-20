import 'package:flutter/material.dart';

/// Classe usada para notificar o novo estado do botão flutuante
class ControleBotaoFlutuante extends ChangeNotifier{
  var _bottom = 16.0;

  get bottom => _bottom;

  set bottom(value) {
    _bottom = value;
    notifyListeners();
  }
}