import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:itens_do_enem/armazenamento.dart';
import 'package:itens_do_enem/item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'globais.dart';

/// Esta classe usa o padrão singleton, isto é, é instanciada uma única vez.
class Dados {
  static final Dados _dados = Dados._interno();
  Dados._interno() {
    _carregarMatriz();
    _carregarItens();
  }
  factory Dados() => _dados;
  List<Item> _subItens = <Item>[];
  final _streamSubItens = StreamController<List<Item>>.broadcast();

  Stream<List<Item>> get streamSubItens => _streamSubItens.stream;

  close() {
    _streamSubItens.close();
  }

  /// Retorna a quantidade de itens após o filtro.
  int filtrar(Map<String, dynamic> filtros) {
    bool recriarSubItens = false; //Indica se algum filtro foi removido
    filtros.forEach((key, value) {
      if (
          //Caso algum filtro tenha sido removido
          (value != filtrosSelecionados[key] && value == null) ||
              //Caso algum filtro tenha sido alterado
              (value != filtrosSelecionados[key] &&
                  filtrosSelecionados[key] != null)) {
        recriarSubItens = true;
        filtrosSelecionados[key] = value;
      }
    });
    if (recriarSubItens) _subItens = itens;
    filtros.forEach((key, value) {
      if ((value != filtrosSelecionados[key] || recriarSubItens) &&
          value != null) {
        filtrosSelecionados[key] = value;
        _subItens = _subItens.where((_) {
          if (key == COL_ANO)
            return _.ano == value;
          else if (key == COL_ID_HABILIDADE)
            return _.idHabilidade == value;
          else
            return false;
        }).toList();
      }
    });
    _streamSubItens.sink.add(_subItens);
    return _subItens.length;
  }

  /// Retorna um Map<String,List<Map>>.
  Future<Map> _carregarJsonFromAsset(String path) async {
    final string = await rootBundle.loadString(path);
    return json.decode(string);
  }

    int _parceIntIfString(source){
    if(source is int) {
      return source;
    }else{
      return int.parse(source);
    }
  }

  _carregarItens() {
    _getItens().then((dados) {
      //anos.addAll(_.keys.cast<int>());
      Set provas = Set<int>();
      dados.forEach((ano, value) {
        anos.add(_parceIntIfString(ano));
        List list = value;
        list.forEach((_) {
          // Definir primeira letra como maiúscula
          idHabilidades.add(_parceIntIfString(_[COL_ID_HABILIDADE]));

          provas.add(_parceIntIfString(_[COL_ID_PROVA]));

          itens.add(Item(
              ano: _parceIntIfString(ano),
              gabarito: _[COL_GABARITO],
              idHabilidade: _parceIntIfString(_[COL_ID_HABILIDADE]),
              idOrdem: _parceIntIfString(_[COL_ID_ORDEM]),
              idProva: _parceIntIfString(_[COL_ID_PROVA]),
              numPageCaderno:
                  _.containsKey(COL_NUM_PAGE_CADERNO)
                      ? _parceIntIfString(_[COL_NUM_PAGE_CADERNO])
                      : 1));
        });
      });
      _subItens.addAll(itens);
      _streamSubItens.sink.add(_subItens);
    });
  }

  Future<Map> _getItens() async {
    File? file = await Armazenamento.getJsonItens();
    if (file == null) {
      final acesso = await Permissao.status;
      if (acesso.isDenied || acesso.isPermanentlyDenied) {
        /* final msg =
            "Se a permissão permanecer como negada o aplicativo carregará "
            "mais lentamente."; */ //TODO
        //Armazenamento.abrirConfiguracoesApp(context, msg);
      }
    } else {
      try {
        // Usar arquivo no armazenamento
        return await json.decode(await file.readAsString());
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
    return await _carregarJsonFromAsset(Armazenamento.ASSETS_JSON_ITENS);
  }

  Future<Map> _getMatriz() async {
    File? file = await Armazenamento.getJsonMatrizDeReferencia();
    if (file == null) {
      final acesso = await Permissao.status;
      if (acesso.isDenied || acesso.isPermanentlyDenied) {
        /* final msg =
            "Se a permissão permanecer como negada o aplicativo carregará "
            "mais lentamente."; */ //TODO
        //Armazenamento.abrirConfiguracoesApp(context, msg);
      }
    } else {
      try {
        // Usar arquivo no armazenamento
        return await json.decode(await file.readAsString());
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
    return await _carregarJsonFromAsset(
        Armazenamento.ASSETS_JSON_MATRIZ_DE_REFERENCIA);
  }

  Future<void> _carregarMatriz() async {
    final map = await _getMatriz();
    // Esse "map" contem apenas um elemento. A key desse elemento é "MT"
    final List list = map["MT"];
    list.forEach((_) {
      final Map map = _;
      final idCompetencia = _parceIntIfString(map[KEY_ID_COMPETENCIA]);
      final idHabilidade = _parceIntIfString(map[KEY_ID_HABILIDADE]);
      Competencia competencia = competencias.putIfAbsent(
        idCompetencia,
        () => Competencia(
          id: idCompetencia,
          descricao: map[KEY_COMPETENCIA],
        ),
      );
      habilidades[idHabilidade] = Habilidade(
        id: idHabilidade,
        descricao: map[KEY_HABILIDADE],
        competencia: competencia,
      );
    });
  }

  /// TODO: Métodos para trabalhar com arquivos.
  /// Ainda não estão sendo usados.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  // ignore: unused_element
  Future<File> _writeInFile(int counter) async {
    final file = await _localFile;
    // Write the file.
    return file.writeAsString('$counter');
  }
}
