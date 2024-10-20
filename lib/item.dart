class Competencia{
  final int id;
  final String descricao;
  Competencia({
    required this.id,
    required this.descricao
  });
}

class Habilidade{
  final int id;
  final String descricao;
  final Competencia competencia;
  Habilidade({
    required this.id,
    required this.descricao,
    required this.competencia
  });
}

class Item{
  final int ano;
  final String gabarito;
  final int idHabilidade;
  final int idOrdem;
  final int idProva;
  final int numPageCaderno;
  late final int competencia;

  Item({
    required this.ano,
    required this.gabarito,
    required this.idHabilidade,
    required this.idOrdem,
    required this.idProva,
    required this. numPageCaderno,
  }) : 
      assert (idHabilidade > 0 && idHabilidade <= 30)
  {
    if (idHabilidade < 6) competencia = 1;
    else if (idHabilidade < 10) competencia = 2;
    else if (idHabilidade < 15) competencia = 3;
    else if (idHabilidade < 19) competencia = 4;
    else if (idHabilidade < 24) competencia = 5;
    else if (idHabilidade < 27) competencia = 6;
    else competencia = 7;
  }
}