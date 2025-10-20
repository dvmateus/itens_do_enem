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
  final int competencia;

  Item({
    required this.ano,
    required this.gabarito,
    required this.idHabilidade,
    required this.idOrdem,
    required this.idProva,
    required this.numPageCaderno,
    int? idCompetencia,
  }) :
      assert(idHabilidade > 0),
      competencia = idCompetencia ?? _competenciaPorHabilidade(idHabilidade);

  static int _competenciaPorHabilidade(int idHabilidade) {
    if (idHabilidade < 6) return 1;
    if (idHabilidade < 10) return 2;
    if (idHabilidade < 15) return 3;
    if (idHabilidade < 19) return 4;
    if (idHabilidade < 24) return 5;
    if (idHabilidade < 27) return 6;
    return 7;
  }
}