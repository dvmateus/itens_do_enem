import 'dart:async';

import 'package:flutter/foundation.dart';

import 'globais.dart';
import 'item.dart';
import 'services/supabase_repository.dart';

class Dados {
  factory Dados() => _dados;

  Dados._interno({SupabaseRepository? repository})
      : _repository = repository ?? SupabaseRepository.instance {
    _initialize();
  }

  static final Dados _dados = Dados._interno();

  final SupabaseRepository _repository;
  List<Item> _subItens = <Item>[];
  final _streamSubItens = StreamController<List<Item>>.broadcast();

  Stream<List<Item>> get streamSubItens => _streamSubItens.stream;

  void _initialize() {
    Future.microtask(() async {
      try {
        await _carregarMatriz();
        await _carregarItens();
      } catch (error, stackTrace) {
        if (kDebugMode) {
          print(error);
        }
        if (!_streamSubItens.isClosed) {
          _streamSubItens.addError(error, stackTrace);
        }
      }
    });
  }

  void close() {
    _streamSubItens.close();
  }

  int filtrar(Map<String, dynamic> filtros) {
    bool recriarSubItens = false;
    filtros.forEach((key, value) {
      if ((value != filtrosSelecionados[key] && value == null) ||
          (value != filtrosSelecionados[key] && filtrosSelecionados[key] != null)) {
        recriarSubItens = true;
        filtrosSelecionados[key] = value;
      }
    });
    if (recriarSubItens) {
      _subItens = List<Item>.from(itens);
    }
    filtros.forEach((key, value) {
      if ((value != filtrosSelecionados[key] || recriarSubItens) && value != null) {
        filtrosSelecionados[key] = value;
        _subItens = _subItens.where((Item item) {
          if (key == COL_ANO) {
            return item.ano == value;
          } else if (key == COL_ID_HABILIDADE) {
            return item.idHabilidade == value;
          } else {
            return false;
          }
        }).toList();
      }
    });
    _streamSubItens.sink.add(_subItens);
    return _subItens.length;
  }

  Future<void> _carregarItens() async {
    final dados = await _repository.fetchItens();
    itens.clear();
    anos.clear();
    idHabilidades.clear();

    for (final registro in dados) {
      final int ano = _parseInt(registro[COL_ANO]);
      final int idHabilidade = _parseInt(registro[COL_ID_HABILIDADE]);
      final int idOrdem = _parseInt(registro[COL_ID_ORDEM]);
      final int idProva = _parseInt(registro[COL_ID_PROVA]);
      final int numPageCaderno = registro.containsKey(COL_NUM_PAGE_CADERNO)
          ? _parseInt(registro[COL_NUM_PAGE_CADERNO])
          : 1;
      final int? idCompetencia = registro.containsKey(COL_ID_COMPETENCIA)
          ? _tryParseInt(registro[COL_ID_COMPETENCIA])
          : null;

      final item = Item(
        ano: ano,
        gabarito: (registro[COL_GABARITO] ?? '').toString(),
        idHabilidade: idHabilidade,
        idOrdem: idOrdem,
        idProva: idProva,
        numPageCaderno: numPageCaderno,
        idCompetencia: idCompetencia,
      );
      itens.add(item);
      anos.add(ano);
      idHabilidades.add(idHabilidade);
    }

    _subItens = List<Item>.from(itens);
    _streamSubItens.add(_subItens);
  }

  Future<void> _carregarMatriz() async {
    final competenciasData = await _repository.fetchCompetencias();
    final habilidadesData = await _repository.fetchHabilidades();

    competencias.clear();
    habilidades.clear();

    for (final dadosCompetencia in competenciasData) {
      final id = _parseInt(dadosCompetencia[KEY_COMPETENCIA_ID]);
      final descricao = dadosCompetencia[KEY_COMPETENCIA_DESCRICAO]?.toString() ?? '';
      competencias[id] = Competencia(id: id, descricao: descricao);
    }

    for (final dadosHabilidade in habilidadesData) {
      final id = _parseInt(dadosHabilidade[KEY_HABILIDADE_ID]);
      final descricao = dadosHabilidade[KEY_HABILIDADE_DESCRICAO]?.toString() ?? '';
      final idCompetencia = _parseInt(dadosHabilidade[KEY_HABILIDADE_COMPETENCIA]);
      final competencia = competencias[idCompetencia];
      if (competencia == null) {
        if (kDebugMode) {
          print('Competência $idCompetencia não encontrada para habilidade $id');
        }
        continue;
      }
      habilidades[id] = Habilidade(
        id: id,
        descricao: descricao,
        competencia: competencia,
      );
    }
  }

  int _parseInt(dynamic source) {
    final parsed = _tryParseInt(source);
    if (parsed == null) {
      throw FormatException('Valor inteiro inválido: $source');
    }
    return parsed;
  }

  int? _tryParseInt(dynamic source) {
    if (source == null) {
      return null;
    }
    if (source is int) {
      return source;
    }
    if (source is double) {
      return source.toInt();
    }
    return int.tryParse(source.toString());
  }
}
