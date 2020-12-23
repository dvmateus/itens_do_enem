import 'package:flutter/material.dart';

class Competencia{
  final int id;
  final String descricao;
  Competencia({
    @required this.id,
    @required this.descricao
  }): assert (id != null),
      assert (descricao != null);
}

class Habilidade{
  final int id;
  final String descricao;
  final Competencia competencia;
  Habilidade({
    @required this.id,
    @required this.descricao,
    @required this.competencia
  }): assert (id != null),
      assert (descricao != null),
      assert (competencia != null);
}

class Item{
  final int ano;
  final String codArea;
  final String corCaderno;
  final String gabarito;
  final int idHabilidade;
  final int idOrdem;
  final int idProva;
  final int serie;
  final int numPageCaderno;
  int _competencia;

  int get competencia => _competencia;

  Item({
    @required this.ano,
    @required this.codArea,
    @required this.corCaderno,
    @required this.gabarito,
    @required this.idHabilidade,
    @required this.idOrdem,
    @required this.idProva,
    @required this.serie,
    int numPageCaderno
  }) : this.numPageCaderno = numPageCaderno,
      assert (idHabilidade > 0 && idHabilidade <= 30)
  {
    if (idHabilidade < 6) _competencia = 1;
    else if (idHabilidade < 10) _competencia = 2;
    else if (idHabilidade < 15) _competencia = 3;
    else if (idHabilidade < 19) _competencia = 4;
    else if (idHabilidade < 24) _competencia = 5;
    else if (idHabilidade < 27) _competencia = 6;
    else _competencia = 7;
  }
}