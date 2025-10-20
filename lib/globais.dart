import 'dart:collection';
import 'package:itens_do_enem/dados.dart';
import 'package:itens_do_enem/item.dart';

// Colunas da tabela `db`
const COL_ID_ORDEM = "ordem";
const COL_GABARITO = "gabarito";
const COL_ID_HABILIDADE = "id_habilidade";
const COL_ID_PROVA = "id_prova";
const COL_ANO = "ano";
const COL_NUM_PAGE_CADERNO = "num_page_caderno";
const COL_ID_COMPETENCIA = "id_competencia";

// Colunas das tabelas de matriz de referência
const KEY_COMPETENCIA_ID = "id";
const KEY_COMPETENCIA_DESCRICAO = "descricao";
const KEY_HABILIDADE_ID = "id";
const KEY_HABILIDADE_DESCRICAO = "descricao";
const KEY_HABILIDADE_COMPETENCIA = "id_competencia";

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
