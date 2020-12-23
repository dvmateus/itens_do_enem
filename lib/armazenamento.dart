import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itens_do_enem/excecoes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class Permicao {
  static Permission get permicao => Permission.storage;

  //Retorna o status da permição para acesso ao armazenamento
  static Future<PermissionStatus> get status => permicao.status;

  static Future<bool> get negada => permicao.isDenied;

  static Future<bool> get negadaPermanentemente => permicao.isPermanentlyDenied;

  //Retorna se foi possível abrir as configurações
  static Future<bool> get abrirConfiguracoes => openAppSettings();

  //Retorna true se a permição for concedida
  static Future<bool> get solicitar async => (await permicao.request()).isGranted;
}

abstract class Armazenamento {
  static const ASSETS_JSON_ITENS = "assets/db.json";
  static const JSON_ITENS = "db.json";
  static const ASSETS_JSON_MATRIZ_DE_REFERENCIA = "assets/matriz_de_referencia.json";
  static const JSON_MATRIZ_DE_REFERENCIA = "matriz_de_referencia.json";
  static const ASSETS_PROVAS = "assets/provas/";

  static Future<Directory> _getDirApp() async {
    Directory dir;
    String pathDir;
    bool hasError;
    bool acessoArmazenamento = await Permicao.solicitar;
    if (acessoArmazenamento){
      try {
        String str = (await getExternalStorageDirectory()).path;
        //Remover de "ndroid" em diante
        str = str.split("ndroid")[0];
        //Remover o "A" ou "a" que restou no final da string
        str = str.substring(0, str.length - 1);
        pathDir = str += "App Itens do ENEM";
        dir = await Directory(pathDir).create(recursive: true);
        hasError = false;
        return dir;
      } catch (e){
        print(e.toString());
        hasError = true;
      }
    }
    else if (await Permicao.negadaPermanentemente){
      print(AcessoAoArmazenamentoNegadoPermanentemente.mensage);
      throw AcessoAoArmazenamentoNegadoPermanentemente();
    }
    else if (await Permicao.negada){
      print(AcessoAoArmazenamentoNegado.mensage);
      throw AcessoAoArmazenamentoNegado();
    }
    else if (!acessoArmazenamento || hasError){
      try{
        dir = await getExternalStorageDirectory();
        return dir;
      } catch (e){
        print("Erro ao buscar o diretório!");
        print(e.toString());
        throw e;
      }
    }
  }

  static Future<Directory> _getDirProvas() async {
    Directory dir;
    String pathDir;
    try {
      pathDir = (await _getDirApp()).path + "/Provas";
      dir = await Directory(pathDir).create(recursive: true);
      return dir;
    }
    //Ocorrido em getDirApp()
    on AcessoAoArmazenamentoNegadoPermanentemente catch (e){
      throw e;
    }
    catch (e){
      print(e.toString());
    }
  }

  static Future<File> _getArquivo(String assetPath, Directory dir, String nome) async {
    File file;
    try{
      if (await File("${dir.path}/$nome").exists()) {
        return file = File("${dir.path}/$nome");
      }
      else {
        file = File("${dir.path}/$nome");
        var data = await rootBundle.load(assetPath);
        var bytes = data.buffer.asUint8List();
        return await file.writeAsBytes(bytes, flush: true);
      }
    }
    catch (e){
      print("Erro ao tentar salvar o arquivo.");
      print(e.toString());
      throw e;
    }
  }

  static Future<File> getJsonItens() async {
    Directory dir;
    try{
      dir = await _getDirApp();
      return await _getArquivo(ASSETS_JSON_ITENS, dir, JSON_ITENS);
    }
    //Ocorrido em getDirApp()
    on AcessoAoArmazenamentoNegadoPermanentemente catch (e){
      throw e;
    }
  }

  static Future<File> getJsonMatrizDeReferencia() async {
    Directory dir;
    try{
      dir = await _getDirApp();
      return await _getArquivo(ASSETS_JSON_MATRIZ_DE_REFERENCIA, dir, JSON_MATRIZ_DE_REFERENCIA);
    }
    //Ocorrido em getDirApp()
    on AcessoAoArmazenamentoNegadoPermanentemente catch (e){
      throw e;
    }
  }

  static Future<File> getProva(int idProva) async {
    Directory dir;
    try{
      dir = await _getDirProvas();
      return await _getArquivo("$ASSETS_PROVAS$idProva.pdf", dir, "$idProva.pdf");
    }
    //Ocorrido em getDirApp()
    on AcessoAoArmazenamentoNegadoPermanentemente catch (e){
      throw e;
    }
  }

  static Future<void> abrirConfiguracoesApp(BuildContext context, String mensagem) async {
    final abrirConfiguracoes = await showDialog<bool>(
      context: context,
      child: AlertDialog(
        title: const Text("Permissão para acesso ao armazenamento"),
        content: const Text(
          "Deseja acessar as configurações do aplicativo para alterar a "
          "permissão de armazenamento?"
        ),
        actions: [
          MaterialButton(
            child: const Text("Não"),
            onPressed: () => Navigator.pop(context, false),
          ),
          MaterialButton(
            child: const Text("Sim"),
            onPressed: () => Navigator.pop(context, true),
          )
        ],
      )
    );
    //Caso o usuário não tenha escolhido "Sim"
    if (abrirConfiguracoes ?? false) return openAppSettings().then((value) {
      if (!value) showDialog(
        context: context,
        child: AlertDialog(
          content: const Text(
            "Não foi possível abrir as configurações do aplicativo. Você "
            "pode acessar essas configurações manualmente."
          ),
          actions: [
            MaterialButton(
              child: const Text("Fechar"),
              onPressed: () => Navigator.pop(context),
            )
          ]
        )
      );
      return value;
    });

    else return showDialog(
      context: context,
      child: AlertDialog(
        content: Text(mensagem),
        actions: [
          MaterialButton(
            child: const Text("Fechar"),
            onPressed: () => Navigator.pop(context),
          )
        ]
      )
    );
  }
}