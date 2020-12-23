import 'package:flutter/material.dart';
import 'bloc_pagina_principal.dart';
import 'controle_status_animacoes.dart';
import 'dialodo_de_selecao.dart';
import 'globais.dart';
import 'itens_data_table_source.dart';
import 'paginated_data_table.dart';
import 'string_conteudo_dialogo_info.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> with SingleTickerProviderStateMixin {
  final _bloc = BlocPaginaPrincipal();
  ScrollController _scrollController;
  ControleBotaoFlutuante _controleBotaoFlutuante;
  bool _deslocar;


  @override
  void initState() {
    super.initState();
    _deslocar = false;
    _controleBotaoFlutuante = ControleBotaoFlutuante();
    _scrollController = ScrollController();
    _scrollController.addListener(_delocarFloatingActionButton);
  }

  @override
  void dispose() {
    _bloc.close;
    _scrollController?.dispose();
    super.dispose();
  }

  void _delocarFloatingActionButton() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 60
        && !_deslocar) {
      _deslocar = true;
      _controleBotaoFlutuante.bottom = 96.0;
    }
    else if (_scrollController.offset <= _scrollController.position.maxScrollExtent - 60
        && _deslocar){
      _deslocar = false;
      _controleBotaoFlutuante.bottom = 16.0;
    }
  }

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
        Expanded(child: Scaffold(
          appBar: AppBar(
            title: const Text("Itens do ENEM"),
            actions: [_botaoSobre()]
          ),
          body: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SingleChildScrollView(
                //padding: const EdgeInsets.only(bottom: 32),
                controller: _scrollController,
                child: StreamBuilder(
                  stream: _bloc.streamSubItens,
                  initialData: itens,
                  builder: (context, snapshot){
                    final _itens = ItensDataTableSource(
                        context: context,
                        itens: snapshot.data);
                    return MeuPaginatedDataTable(
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
                      source: _itens
                    );
                  },
                ),
              ),
              _botaoFlutuante()
            ],
          )
        ),
        )])
    );
  }

  Widget _botaoSobre(){
    return IconButton(
      icon: const Icon(Icons.info),
      onPressed: () => showDialog(
        context: context,
        child: AlertDialog(
          insetPadding: EdgeInsets.fromLTRB(16, 72, 16, 40),
          title: const Text("Itens do ENEM"),
          content: const SingleChildScrollView(
            child: const Text(CONTEUDO_DIALOGO_INFO)
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar")
            )
          ],
        )
      ),
    );
  }

  Widget _botaoFiltrar(){
    return IconButton(
      icon: const Icon(Icons.filter_alt_sharp,),
      onPressed: () => showDialog(context: context, child: DialogoSelecao()),
      );
  }

  List<DataColumn>_colunas(ItensDataTableSource _itens) => [
    DataColumn(
        label: Row(children: [
          const Text("ANO"),
          //const Icon(Icons.keyboard_arrow_down_rounded,)
        ],),
        onSort: (colIndex, ascending){
          _bloc.sort<num>((item)
          => item.ano, colIndex, ascending, _itens, _bloc.provider);
        }
    ),
    //const DataColumn(label: const Text("AREA")),
    DataColumn(
        label: const Text("CADERNO"),
        onSort: (colIndex, ascending){
          _bloc.sort<String>((item)
          => item.corCaderno, colIndex, ascending, _itens, _bloc.provider);
        }
    ),
    DataColumn(
        label: const Text("ORDEM"),
        onSort: (colIndex, ascending){
          _bloc.sort<num>((item)
          => item.idOrdem, colIndex, ascending, _itens, _bloc.provider);
        }
    ),
    DataColumn(
        label: const Text("GABARITO"),
        onSort: (colIndex, ascending){
          _bloc.sort<String>((item)
          => item.gabarito, colIndex, ascending, _itens, _bloc.provider);
        }
    ),
    DataColumn(
        label: const Text("ID HABILIDADE"),
        onSort: (colIndex, ascending){
          _bloc.sort<num>((item)
          => item.idHabilidade, colIndex, ascending, _itens, _bloc.provider);
        }
    ),
    DataColumn(
        label: const Text("ID PROVA"),
        onSort: (colIndex, ascending){
          _bloc.sort<num>((item)
          => item.idProva, colIndex, ascending, _itens, _bloc.provider);
        }
    )
    //, const DataColumn(label: const Text("SERIE"))
  ];

  Widget _botaoFlutuante() {
    return AnimatedBuilder(
      animation: _controleBotaoFlutuante,
      builder: (context, widget){
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          right: 16,
          bottom: _controleBotaoFlutuante.bottom,
          child: FloatingActionButton(
            child: const Icon(Icons.filter_alt_sharp,),
            onPressed: () => showDialog(context: context, child: DialogoSelecao()),
          ),
        );
      },
    );
  }
}