import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:itens_do_enem/armazenamento.dart';
import 'package:itens_do_enem/excecoes.dart';
import 'package:itens_do_enem/item.dart';
import 'package:path_provider/path_provider.dart';
import 'globais.dart';

//Esta classe usa o padrão singleton, isto é, é instanciada uma unica vez
class Dados {
  static final Dados _dados = Dados._interno();
  Dados._interno(){
    _carregarMatriz();
    _carregarItens();
  }
  factory Dados() => _dados;
  List<Item> _subItens = List<Item>();
  final _streamSubItens = StreamController<List<Item>>.broadcast();

  Stream<List<Item>> get streamSubItens => _streamSubItens.stream;

  close() {
    _streamSubItens.close();
  }

  //Retorna a quantidade de itens após o filtro
  int filtrar(Map<String, dynamic> filtros){
    bool recriarSubItens = false; //Indica se algum filtro foi removido
    filtros.forEach((key, value) {
      if (
        //Caso algum filtro tenha sido removido
        (value != filtrosSelecionados[key] && value == null) ||
        //Caso algum filtro tenha sido alterado
        (value != filtrosSelecionados[key] && filtrosSelecionados[key] != null)
      ) {
        recriarSubItens = true;
        filtrosSelecionados[key] = value;
      }
    });
    if (recriarSubItens) _subItens = itens;
    filtros.forEach((key, value) {
      if ((value != filtrosSelecionados[key] || recriarSubItens) && value != null) {
        filtrosSelecionados[key] = value;
        _subItens = _subItens.where((_) {
          if (key == COL_ANO) return _.ano == value;
          else if (key == COL_COR_CADERNO) return _.corCaderno == value;
          else if (key == COL_ID_HABILIDADE) return _.idHabilidade == value;
          else return false;
        }).toList();
      }
    });
    _streamSubItens.sink.add(_subItens);
    return _subItens.length;
  }

  //Retorna um Map<String,List<Map>>
  Future<Map> _carregarJsonFromAsset (String path) async {
    return rootBundle.loadString(path).then((_) => json.decode(_));
  }

  _carregarItens(){
    _getItens().then((_){
      //anos.addAll(_.keys.cast<int>());
      Set provas = Set<int>();
      _.forEach((ano, value) {
        anos.add(int.parse(ano));
        List list = value;
        list.forEach((_) {
          //Definir primeira letra como maiúscula
          final corCaderno = _[COL_COR_CADERNO].substring(0,1)
            + _[COL_COR_CADERNO].substring(1).toLowerCase();
          coresCadernos.add(corCaderno);
          idHabilidades.add(int.parse(_[COL_ID_HABILIDADE]));

          provas.add(int.parse(_[COL_ID_PROVA]));

          itens.add(Item(ano: int.parse(ano),
            codArea: _[COL_COD_AREA],
            corCaderno: corCaderno,
            gabarito: _[COL_GABARITO],
            idHabilidade: int.parse(_[COL_ID_HABILIDADE]),
            idOrdem: int.parse(_[COL_ID_ORDEM]),
            idProva: int.parse(_[COL_ID_PROVA]),
            serie: int.parse(_[COL_SERIE]),
            numPageCaderno: corCaderno == "Cinza" && _.containsKey(COL_NUM_PAGE_CADERNO)
              ? int.parse(_[COL_NUM_PAGE_CADERNO]) : null
          ));
        });
      });
      _subItens.addAll(itens);
      _streamSubItens.sink.add(_subItens);
    });
  }

  Future<Map> _getItens() async {
    File file;
    try{
      //Usar arquivo no armazenamento
      file = await Armazenamento.getJsonItens();
      return await json.decode(await file.readAsString());
    }
    //Ocorrido em getDirProvas()
    on AcessoAoArmazenamentoNegadoPermanentemente {
      final msg = "Se a permissão permanecer como negada o aplicativo carregará "
          "mais lentamente.";
      //Armazenamento.abrirConfiguracoesApp(context, msg);
      return await _carregarJsonFromAsset(Armazenamento.ASSETS_JSON_ITENS);
    }
    catch (e) {
      print(e.toString());
      return await _carregarJsonFromAsset(Armazenamento.ASSETS_JSON_ITENS);
    }
  }

  Future<Map> _getMatriz() async {
    File file;
    try{
      //Usar arquivo no armazenamento
      file = await Armazenamento.getJsonMatrizDeReferencia();
      return await json.decode(await file.readAsString());
    }
    //Ocorrido em getDirProvas()
    on AcessoAoArmazenamentoNegadoPermanentemente {
      final msg = "Se a permissão permanecer como negada o aplicativo carregará "
          "mais lentamente.";
      //Armazenamento.abrirConfiguracoesApp(context, msg);
      return await _carregarJsonFromAsset(Armazenamento.ASSETS_JSON_MATRIZ_DE_REFERENCIA);
    }
    catch (e) {
      print(e.toString());
      return await _carregarJsonFromAsset(Armazenamento.ASSETS_JSON_MATRIZ_DE_REFERENCIA);
    }
  }

  Future<void> _carregarMatriz() async {
    final map = await _getMatriz();
    //Esse "map" contem apenas um elemento. A key desse elemento é "MT"
    final List list = map["MT"];
    list.forEach((_) {
      final Map map = _;
      final idCompetencia = int.parse(map[KEY_ID_COMPETENCIA]);
      final idHabilidade = int.parse(map[KEY_ID_HABILIDADE]);
      Competencia competencia;
      if (competencias.containsKey(idCompetencia)) competencia = competencias[idCompetencia];
      else {
        competencia = Competencia(id: idCompetencia, descricao: map[KEY_COMPETENCIA]);
        competencias[idCompetencia] = competencia;
      }
      habilidades[idHabilidade] = Habilidade(
          id: idHabilidade,
          descricao: map[KEY_HABILIDADE],
          competencia: competencia
      );
    });
  }





  //Métodos para trabalhar com arquivos.
  //Ainda não estão sendo usados.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }
  Future<File> _writeInFile(int counter) async {
    final file = await _localFile;
    // Write the file.
    return file.writeAsString('$counter');
  }
}