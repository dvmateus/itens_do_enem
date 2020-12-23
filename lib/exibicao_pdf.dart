import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:itens_do_enem/armazenamento.dart';
import 'package:itens_do_enem/globais.dart';
import 'package:itens_do_enem/item.dart';

import 'excecoes.dart';

const _CADERNO_CINZA = "Cinza";

class ExibicaoPDF extends StatefulWidget {
  Item _item;
  int _idProva;

  ExibicaoPDF({Key key, Item item}) : this._item = item, assert (item != null), super(key: key){
    if (item.corCaderno != _CADERNO_CINZA) _item = itens.firstWhere((_) =>
      _.corCaderno == _CADERNO_CINZA
      && _.ano == item.ano
      && _.serie == item.serie
    );
    _idProva = _item.idProva;
  }

  @override
  _ExibicaoPDFState createState() => _ExibicaoPDFState();
}

class _ExibicaoPDFState extends State<ExibicaoPDF> {
  PDFDocument _doc;
  _ControleAnimacaoCarregamento _controleAnimacaoCarregamento;
  _ControleAnimacaoBanner _controleAnimacaoBanner = _ControleAnimacaoBanner();
  PageController _pageController;

  Future<PDFDocument> _getProva(int idProva) async {
    File file;
    try{
      //Usar arquivo no armazenamento
      file = await Armazenamento.getProva(idProva);
      return await PDFDocument.fromFile(file);
    }
    //Ocorrido em getDirProvas()
    on AcessoAoArmazenamentoNegadoPermanentemente {
      final msg = "Se a permissão permanecer como negada as provas serão carregadas "
          "mais lentamente.";
      Armazenamento.abrirConfiguracoesApp(context, msg);
      return _getProvaFromAsset(idProva);
    }
    catch (e) {
      //Caso não seja possível usar o arquivo no armazenamento
      return _getProvaFromAsset(idProva);
    }
  }

  static Future<PDFDocument> _getProvaFromAsset(int idProva) async {
    return await PDFDocument.fromAsset(
        "${Armazenamento.ASSETS_PROVAS}$idProva.pdf"
    );
  }

  @override
  void initState() {
    _controleAnimacaoCarregamento = _ControleAnimacaoCarregamento(context);
    if (widget._item.numPageCaderno != null)
      _pageController = PageController(initialPage: widget._item.numPageCaderno -1);
    _getProva(widget._idProva).then((_) {
      _doc = _;
      _controleAnimacaoCarregamento.state = true;
    }).catchError((erro){
      if (!_controleAnimacaoCarregamento.ocorreuErro)
        _controleAnimacaoCarregamento.ocorreuErro = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item ${widget._item.idOrdem}  -  Gabarito ${widget._item.gabarito}"),
      ),
      body: Center(child: AnimatedBuilder(
        animation: _controleAnimacaoCarregamento,
        builder: (context, widget){
          return AnimatedContainer(
            child: _doc == null
              ? const CircularProgressIndicator()
              : Column(children: [
                Expanded(child: Stack(
                  children: [
                    PDFViewer(
                      document: _doc,
                      controller: _pageController,
                    ),
                    //Criar banner de aviso
                    _gerarBanner()
                  ]
                ))
              ]
            ),
            duration: const Duration(milliseconds: 300)
          );
        }
      ))
    );
  }

  Widget _gerarBanner() {
    return AnimatedBuilder(
      animation: _controleAnimacaoBanner,
      builder: (context, widget){
        return AnimatedContainer(
          padding: const EdgeInsets.only(left: 32, bottom: 16),
          color: Colors.black.withOpacity(0.65),
          width: double.maxFinite,
          height: _controleAnimacaoBanner.altura,
          duration: const Duration(milliseconds: 300),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(
                "Procure pela questão ${this.widget._item.idOrdem}.",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400
                ),
              )),
              Align(
                alignment: Alignment.topRight,
                child: _controleAnimacaoBanner.altura == 0 ? null : IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => _controleAnimacaoBanner.altura = 0,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerRight,
                )
              )
            ],
          ),
        );
      }
    );
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
      child: AlertDialog(
        content: const Text("Não foi possível localizar o caderno!"),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),//Fechar o AlertDialog
            child: const Text("Fechar")
          )
        ],
      )
    ).then((_) => Navigator.pop(context));//Fechar ExibicaoPDF
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
