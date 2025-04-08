import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:itens_do_enem/armazenamento.dart';
import 'package:itens_do_enem/item.dart';

import 'excecoes.dart';

class ExibicaoPDF extends StatefulWidget {
  final Item item;

  ExibicaoPDF({Key? key, required this.item}) : super(key: key);

  _ExibicaoPDFState createState() => _ExibicaoPDFState();
}

class _ExibicaoPDFState extends State<ExibicaoPDF> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  late int? currentPage = widget.item.numPageCaderno - 1;
  bool isReady = false;
  String errorMessage = '';
  File? _doc;
  late _ControleAnimacaoCarregamento _controleAnimacaoCarregamento;
  _ControleAnimacaoBanner _controleAnimacaoBanner = _ControleAnimacaoBanner();

  Future<File?> _getProva(int idProva) async {
    File? file;
    try {
      //Usar arquivo no armazenamento
      file = await Armazenamento.getProva(idProva);
      return file;
    }
    //Ocorrido em getDirProvas()
    on AcessoAoArmazenamentoNegadoPermanentemente {
      final msg =
          "Se a permissão permanecer como negada as provas serão carregadas "
          "mais lentamente.";
      Armazenamento.abrirConfiguracoesApp(context, msg);
      return null;
    } catch (e) {
      //Caso não seja possível usar o arquivo no armazenamento
      return null;
    }
  }

  @override
  void initState() {
    _controleAnimacaoCarregamento = _ControleAnimacaoCarregamento(context);
    _getProva(widget.item.idProva).then((file) {
      _doc = file;
      _controleAnimacaoCarregamento.state = true;
    }).catchError((erro) {
      if (!_controleAnimacaoCarregamento.ocorreuErro)
        _controleAnimacaoCarregamento.ocorreuErro = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Item ${widget.item.idOrdem}  -  ${widget.item.gabarito == "X" ? "ANULADO" : "Gabarito " + widget.item.gabarito}",
        ),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controleAnimacaoCarregamento,
          builder: (context, widget) {
            return AnimatedContainer(
                child: _doc == null
                    ? const CircularProgressIndicator()
                    : _buildPDFView(),
                duration: const Duration(milliseconds: 300));
          },
        ),
      ),
    );
  }

  Column _buildPDFView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PDFView(
                filePath: _doc!.path,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: currentPage!,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation:
                    false, // if set to true the link is handled in flutter
                onRender: (_pages) {
                  setState(() {
                    pages = _pages;
                    isReady = true;
                  });
                },
                onError: (error) {
                  setState(() {
                    errorMessage = error.toString();
                  });
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = '$page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                },
                onLinkHandler: (String? uri) {
                  print('goto uri: $uri');
                },
                onPageChanged: (int? page, int? total) {
                  print('page change: ${page ?? 0 + 1}/$total');
                  setState(() {
                    currentPage = page;
                  });
                },
              ),

              //Criar banner de aviso
              _gerarBanner(),
              Center(
                child: Text(errorMessage), //TODO: Melhorar o widget da mensagem de erro
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _gerarBanner() {
    return AnimatedBuilder(
        animation: _controleAnimacaoBanner,
        builder: (context, widget) {
          return AnimatedContainer(
            padding: const EdgeInsets.only(left: 32, bottom: 16),
            color: Colors.black.withAlpha(165),
            width: double.maxFinite,
            height: _controleAnimacaoBanner.altura,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Text(
                  "Procure pela questão ${this.widget.item.idOrdem}.",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400),
                )),
                Align(
                    alignment: Alignment.topRight,
                    child: _controleAnimacaoBanner.altura == 0
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () => _controleAnimacaoBanner.altura = 0,
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            alignment: Alignment.centerRight,
                          ))
              ],
            ),
          );
        });
  }
}

class _ControleAnimacaoCarregamento extends ChangeNotifier {
  _ControleAnimacaoCarregamento(this.context);
  final BuildContext context;
  bool _state = false;
  bool _ocorreuErro = false;

  bool get state => _state;
  bool get ocorreuErro => _ocorreuErro;

  set ocorreuErro(bool value) {
    _ocorreuErro = value;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Não foi possível localizar o caderno!"),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context), //Fechar o AlertDialog
              child: const Text("Fechar"),
            )
          ],
        );
      },
    ).then((_) => Navigator.pop(context)); //Fechar ExibicaoPDF
  }

  set state(bool value) {
    _state = value;
    notifyListeners();
  }
}

class _ControleAnimacaoBanner extends ChangeNotifier {
  double _altura = 80;

  double get altura => _altura;

  set altura(double value) {
    _altura = value;
    notifyListeners();
  }
}
