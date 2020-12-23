import 'package:flutter/material.dart';
import 'package:itens_do_enem/exibicao_pdf.dart';
import 'package:itens_do_enem/globais.dart';
import 'package:itens_do_enem/item.dart';

class ItensDataTableSource extends DataTableSource{
  ItensDataTableSource({
    @required this.context,
    @required this.itens,
  }): assert (debugCheckHasMaterialLocalizations(context)),
      assert (itens != null);

  final BuildContext context;
  final List<Item> itens;

  @override
  DataRow getRow(int index) {
    final _item = itens[index];
    return DataRow.byIndex(
      onSelectChanged: (_) => _onSelectChanged(habilidades[_item.idHabilidade], _item),
      index: index,
      cells: [
        DataCell(Text(_item.ano.toString())),
        //DataCell(Text(_item.cod_area)),
        DataCell(Text(_item.corCaderno)),
        DataCell(Text(_item.idOrdem.toString())),
        DataCell(Text(_item.gabarito)),
        DataCell(Text(_item.idHabilidade.toString())),
        DataCell(Text(_item.idProva.toString()))
        //, DataCell(Text(_item.serie.toString()))
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => itens.length;

  @override
  int get selectedRowCount => 0;

  void _onSelectChanged(Habilidade hab, Item item){
    showDialog(
      context: context,
      child: AlertDialog(
        insetPadding: EdgeInsets.fromLTRB(16, 72, 16, 40),
        title: Text("Competência de área ${hab.competencia.id} - ${hab.competencia.descricao}"),
        content: Text("H${hab.id} - ${hab.descricao}"),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => ExibicaoPDF(item: item)
            )),
            child: const Text("Ver prova")
          ),
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar")
          )
        ],
      )
    );
  }

  void sort<T>(
      Comparable<T> Function(Item item) getField,
      bool ascending,
  ){
    itens.sort((a, b){
      final aValor = getField(a);
      final bValor = getField(b);
      return ascending
        ? Comparable.compare(aValor, bValor)
        : Comparable.compare(bValor, aValor);
    });
    notifyListeners();
  }
}