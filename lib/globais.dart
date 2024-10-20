import 'dart:collection';
import 'package:itens_do_enem/dados.dart';
import 'package:itens_do_enem/item.dart';

//Keys de db.json
const COL_ID_ORDEM = "COL_ID_ORDEM";
const COL_GABARITO = "COL_GABARITO";
const COL_ID_HABILIDADE = "COL_ID_HABILIDADE";
const COL_ID_PROVA = "COL_ID_PROVA";
const COL_ANO = "COL_ANO";
const COL_NUM_PAGE_CADERNO = "COL_NUM_PAGE_CADERNO";

//Keys de matriz_de_referencia.json
const KEY_ID_COMPETENCIA = "ID_COMPETENCIA";
const KEY_COMPETENCIA = "COMPETENCIA";
const KEY_ID_HABILIDADE = "ID_HABILIDADE";
const KEY_HABILIDADE = "HABILIDADE";

List<Item> itens = <Item>[];
Map<int, Competencia> competencias = Map<int, Competencia>();
Map<int, Habilidade> habilidades = Map<int, Habilidade>();

Dados dados = Dados();

//Variáveis para filtros
//Um Set (conjunto) classificado como SplayTreeSet itera os elementos em ordem classificada.
SplayTreeSet<int> anos = SplayTreeSet<int>();
SplayTreeSet<int> idHabilidades = SplayTreeSet<int>();
Map<String, dynamic> filtrosSelecionados = {
  COL_ANO: null,
  COL_ID_HABILIDADE: null
};
/*
Map<String, Set> filtrosSelecionados = {
  COL_ANO: Set<int>(),
  COL_COR_CADERNO: Set<String>(),
  COL_ID_HABILIDADE: Set<int>()
};*/
