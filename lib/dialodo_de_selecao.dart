import 'dart:async';

import 'package:flutter/material.dart';
import 'package:itens_do_enem/globais.dart';

class DialogoSelecao extends StatefulWidget {
  @override
  _DialogoSelecaoState createState() => _DialogoSelecaoState();
}

class _DialogoSelecaoState extends State<DialogoSelecao> {
  Map<String, dynamic> _tempFiltros = Map.from(filtrosSelecionados);
  final _streamFiltros = StreamController<Map<String, dynamic>>.broadcast();
  get streamFiltros => _streamFiltros.stream;

  @override
  void dispose() {
    _streamFiltros.close();
    super.dispose();
  }

  void _removerFiltro({String? opcao}) {
    if (opcao == null)
      _tempFiltros.keys.forEach((_) => _tempFiltros[_] = null);
    else
      _tempFiltros[opcao] = null;
    _streamFiltros.sink.add(_tempFiltros);
  }

  void _adcionarFiltro(String opcao, filtro) {
    if (_tempFiltros[opcao] != filtro) {
      _tempFiltros[opcao] = filtro;
      _streamFiltros.sink.add(_tempFiltros);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Filtrar"),
      children: [
        Column(
          children: [
            _gerarListTile(COL_ANO),
            _gerarListTile(COL_ID_HABILIDADE),
            OverflowBar(
              children: [
                StreamBuilder(
                    stream: streamFiltros,
                    initialData: _tempFiltros,
                    builder: (context, snapshot) {
                      final map = snapshot.data ?? Map<String, dynamic>();
                      bool ativar = false;
                      map.values.forEach((_) => ativar = ativar || _ != null);
                      return MaterialButton(
                          onPressed: ativar ? () => _removerFiltro() : null,
                          child: Text("Limpar"));
                    }),
                MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar")),
                StreamBuilder(
                  stream: streamFiltros,
                  initialData: _tempFiltros,
                  builder: (context, snapshot) {
                    final map = snapshot.data ?? Map<String, dynamic>();
                    bool ativar = false;
                    map.keys.forEach((_) => ativar =
                        ativar || _tempFiltros[_] != filtrosSelecionados[_]);
                    return MaterialButton(
                      onPressed: !ativar
                          ? null
                          : () {
                              if (dados.filtrar(_tempFiltros) == 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          "Não há itens com essas informações"),
                                      content: const Text(
                                          "Altere os parâmetros de filtro"),
                                      actions: [
                                        MaterialButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Ok"),
                                        )
                                      ],
                                    );
                                  },
                                );
                                _streamFiltros.sink.add(_tempFiltros);
                              } else
                                Navigator.pop(context);
                            },
                      child: Text("Aplicar"),
                    );
                  },
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _gerarListTile(String opcao) {
    var titulo1; //Usado no diálogo principal
    var titulo2; //Usado no diálogo de escolha
    List opcoesEscolha;
    opcoesEscolha = anos.toList();
    switch (opcao) {
      case COL_ANO:
        titulo1 = "Ano";
        titulo2 = "Escolha o ano da prova";
        opcoesEscolha = anos.toList();
        break;
      case COL_ID_HABILIDADE:
        titulo1 = "Habilidade";
        titulo2 = "Escolha uma habilidade";
        opcoesEscolha = idHabilidades.toList();
        break;
    }
    return ListTile(
      contentPadding: EdgeInsets.only(left: 24, right: 24),
      title: Text(titulo1),
      onTap: () => _dialogoEscolher(titulo2, opcoesEscolha, opcao).then((_) {
        //O teste é verdadeiro se o diálogo for fechado sem clicar em nenhuma das opcões
        if (_ != null) _adcionarFiltro(opcao, _);
      }),
      trailing: StreamBuilder(
        stream: streamFiltros,
        initialData: filtrosSelecionados,
        builder: (context, snapshot) {
          if (_tempFiltros[opcao] == null)
            return SizedBox();
          else
            return InputChip(
              label: Text(opcao == COL_ID_HABILIDADE
                  ? "H${_tempFiltros[opcao]}"
                  : _tempFiltros[opcao].toString()),
              onDeleted: () => _removerFiltro(opcao: opcao),
            );
        },
      ),
    );
  }

  Future _dialogoEscolher(String titulo, List opcoesEscolha, opcao) {
    //Retorna a opção escolhida
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(titulo),
          children: List.generate(
            opcoesEscolha.length,
            (index) {
              final opcaoEscolhida = opcoesEscolha[index];
              return SimpleDialogOption(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(opcao == COL_ID_HABILIDADE
                        ? "H${opcaoEscolhida}"
                        : opcaoEscolhida.toString()),
                    Icon(
                      Icons.check,
                      color: _tempFiltros[opcao] == opcaoEscolhida
                          ? Theme.of(context).colorScheme.primary
                          : Colors
                              .transparent, //Theme.of(context).disabledColor
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, opcaoEscolhida);
                },
              );
            },
          ),
        );
      },
    );
  }
}
