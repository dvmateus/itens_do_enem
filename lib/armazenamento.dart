import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class Permissao {
  static Permission get armazenamento => Permission.storage;

  /// Retorna o status da permissão para acesso ao armazenamento.
  static Future<PermissionStatus> get status => armazenamento.status;

  static Future<bool> get negada => armazenamento.isDenied;

  static Future<bool> get negadaPermanentemente =>
      armazenamento.isPermanentlyDenied;

  /// Abre o aplicativo de configurações. Retorna se foi possível abrir as configurações.
  static Future<bool> get abrirConfiguracoes => openAppSettings();

  /// Retorna true se a permissão for concedida.
  static Future<bool> get solicitarAcessoArmazenamento async =>
      (await armazenamento.request()).isGranted;
}

abstract class Armazenamento {
  static const ASSETS_JSON_ITENS = "assets/db.json";
  static const JSON_ITENS = "db.json";
  static const ASSETS_JSON_MATRIZ_DE_REFERENCIA =
      "assets/matriz_de_referencia.json";
  static const JSON_MATRIZ_DE_REFERENCIA = "matriz_de_referencia.json";
  static const ASSETS_PROVAS = "assets/provas/";

  /// No Android: Retorna assincronamente o diretório reservado aos arquivos do aplicativo no armazenamento local.
  /// Se não for possível, fáz o mesmo que para o IOS.
  /// No IOS: Retorna assincronamente o diretório onde o aplicativo pode colocar dados gerados pelo usuário ou que não
  /// podem ser recriados pelo aplicativo.
  /// Retorna `null` se o diretório não for encontrado.
  static Future<Directory?> _getAppDocDir() async {
    if (Platform.isAndroid) {
      final a = (await getExternalStorageDirectory());
      final b = await getApplicationDocumentsDirectory();
      return a ?? b;
    } else {
      try {
        return getApplicationDocumentsDirectory();
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        return null;
      }
    }
  }

  static Future<Directory?> _getDirProvas() async {
    Directory dir;
    final pathDirApp = (await _getAppDocDir())?.path;
    if (pathDirApp == null) {
      return null;
    }
    final pathDir = pathDirApp + "/Provas";
    try {
      dir = await Directory(pathDir).create(recursive: true);
      return dir;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  static Future<File?> _getArquivo(
    String assetPath,
    Directory dir,
    String nome,
  ) async {
    final file = File("${dir.path}/$nome");
    try {
      if (await file.exists()) {
        return file;
      } else {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes, flush: true);
        return file;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao tentar salvar o arquivo.");
        print(e.toString());
      }
      return null;
    }
  }

  static Future<File?> getJsonItens() async {
    Directory? dir = await _getAppDocDir();
    if (dir == null) {
      return null;
    }
    final file = await _getArquivo(
      ASSETS_JSON_ITENS,
      dir,
      JSON_ITENS,
    );
    return file;
  }

  static Future<File?> getJsonMatrizDeReferencia() async {
    Directory? dir = await _getAppDocDir();
    if (dir == null) {
      return null;
    }
    final file = await _getArquivo(
      ASSETS_JSON_MATRIZ_DE_REFERENCIA,
      dir,
      JSON_MATRIZ_DE_REFERENCIA,
    );
    return file;
  }

  static Future<File?> getProva(int idProva) async {
    Directory? dir = await _getDirProvas();
    if (dir == null) {
      return null;
    }
    final file = await _getArquivo(
      "$ASSETS_PROVAS$idProva.pdf",
      dir,
      "$idProva.pdf",
    );
    return file;
  }

  static Future<void> abrirConfiguracoesApp(
    BuildContext context,
    String mensagem,
  ) async {
    final abrirConfiguracoes = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permissão para acesso ao armazenamento"),
          content: const Text(
              "Deseja acessar as configurações do aplicativo para alterar a "
              "permissão de armazenamento?"),
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
        );
      },
    );
    if (abrirConfiguracoes ?? false) {
      // Caso o usuário tenha escolhido "Sim"
      final sucesso = await openAppSettings();
      if (!sucesso) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                  "Não foi possível abrir as configurações do aplicativo. Você "
                  "pode acessar essas configurações manualmente."),
              actions: [
                MaterialButton(
                  child: const Text("Fechar"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(mensagem),
            actions: [
              MaterialButton(
                child: const Text("Fechar"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }
  }
}
