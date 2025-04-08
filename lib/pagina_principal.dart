import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bloc_pagina_principal.dart';
import 'controle_status_animacoes.dart';
import 'dialodo_de_selecao.dart';
import 'globais.dart';
import 'itens_data_table_source.dart';
import 'string_conteudo_dialogo_info.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal>
    with SingleTickerProviderStateMixin {
  final _bloc = BlocPaginaPrincipal();
  late ScrollController _scrollController;
  late ControleBotaoFlutuante _controleBotaoFlutuante;
  bool _deslocar = false;

  @override
  void initState() {
    super.initState();
    _controleBotaoFlutuante = ControleBotaoFlutuante();
    _scrollController = ScrollController();
    _scrollController.addListener(_delocarFloatingActionButton);
  }

  @override
  void dispose() {
    _bloc.close;
    _scrollController.dispose();
    super.dispose();
  }

  void _delocarFloatingActionButton() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 60 &&
        !_deslocar) {
      _deslocar = true;
      _controleBotaoFlutuante.bottom = 96.0;
    } else if (_scrollController.offset <=
            _scrollController.position.maxScrollExtent - 60 &&
        _deslocar) {
      _deslocar = false;
      _controleBotaoFlutuante.bottom = 16.0;
    }
  }

  // ignore: unused_element
  Widget _getIconSort(bool ascendente) => ascendente
      ? const Icon(Icons.keyboard_arrow_down_rounded)
      : const Icon(Icons.keyboard_arrow_up_rounded);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(children: [
          //Criar um SizedBox com a altura da barra de status
          //SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: Scaffold(
                appBar: AppBar(
                    title: const Text("Itens do ENEM"),
                    actions: [_botaoSobre()]),
                body: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SingleChildScrollView(
                      //padding: const EdgeInsets.only(bottom: 32),
                      controller: _scrollController,
                      child: StreamBuilder(
                        stream: _bloc.streamSubItens,
                        initialData: itens,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Erro ao carregar os itens");
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasData) {
                            final _itens = ItensDataTableSource(
                              context: context,
                              itens: snapshot.data!,
                            );
                            return PaginatedDataTable(
                                //sortColumnIndex: 1,
                                //sortAscending: true,
                                showCheckboxColumn: false,
                                columnSpacing: 4,
                                rowsPerPage: 30,
                                //availableRowsPerPage: [20,30,40,50],
                                //onRowsPerPageChanged: (_){},
                                //header: const Text(""),
                                //actions: [_botaoFiltrar()],
                                columns: _colunas(_itens),
                                source: _itens);
                          }
                          return const Text("Nenhum item encontrado");
                        },
                      ),
                    ),
                    _botaoFlutuante()
                  ],
                )),
          )
        ]));
  }

  Widget _botaoSobre() {
    return IconButton(
      icon: const Icon(Icons.info),
      onPressed: () => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.fromLTRB(16, 64, 16, 16),
            title: const Text("Itens do ENEM"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(CONTEUDO_DIALOGO_INFO),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.tryParse(LINK_POLITICA_PRIVACIDADE);
                      if (url == null) {
                        showDialogErroCarregarPolitica(context);
                      } else if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        showDialogErroCarregarPolitica(context);
                      }
                    },
                    child: const Text("Política de Privacidade"),
                  ),
                ],
              ),
            ),
            actions: [botaoFechar(context)],
          );
        },
      ),
    );
  }

  Future<dynamic> showDialogErroCarregarPolitica(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(ERRO_CARREGAR_PAGINA),
          actions: [botaoFechar(context)],
        );
      },
    );
  }

  MaterialButton botaoFechar(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Fechar"),
    );
  }

  List<DataColumn> _colunas(ItensDataTableSource _itens) => [
        DataColumn(
            label: Row(
              children: [
                const Text("ANO"),
                //const Icon(Icons.keyboard_arrow_down_rounded,)
              ],
            ),
            onSort: (colIndex, ascending) {
              _bloc.sort<num>((item) => item.ano, colIndex, ascending, _itens,
                  _bloc.provider);
            }),
        DataColumn(
            label: const Text("ORDEM"),
            onSort: (colIndex, ascending) {
              _bloc.sort<num>((item) => item.idOrdem, colIndex, ascending,
                  _itens, _bloc.provider);
            }),
        DataColumn(
            label: const Text("GABARITO"),
            onSort: (colIndex, ascending) {
              _bloc.sort<String>((item) => item.gabarito, colIndex, ascending,
                  _itens, _bloc.provider);
            }),
        DataColumn(
            label: const Text("HABILIDADE"),
            onSort: (colIndex, ascending) {
              _bloc.sort<num>((item) => item.idHabilidade, colIndex, ascending,
                  _itens, _bloc.provider);
            }),
        DataColumn(
            label: const Text("ID PROVA"),
            onSort: (colIndex, ascending) {
              _bloc.sort<num>((item) => item.idProva, colIndex, ascending,
                  _itens, _bloc.provider);
            })
        //, const DataColumn(label: const Text("SERIE"))
      ];

  Widget _botaoFlutuante() {
    return AnimatedBuilder(
      animation: _controleBotaoFlutuante,
      builder: (context, widget) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          right: 16,
          bottom: _controleBotaoFlutuante.bottom,
          child: FloatingActionButton(
            child: const Icon(
              Icons.filter_alt_sharp,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DialogoSelecao(),
            ),
          ),
        );
      },
    );
  }
}
