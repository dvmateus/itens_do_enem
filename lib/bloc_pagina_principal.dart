import 'package:itens_do_enem/globais.dart';
import 'package:itens_do_enem/item.dart';
import 'package:itens_do_enem/itens_data_table_source.dart';

class BlocPaginaPrincipal {
  static final BlocPaginaPrincipal _blocPaginaPrincipal =
      BlocPaginaPrincipal._interno();
  BlocPaginaPrincipal._interno();
  factory BlocPaginaPrincipal() => _blocPaginaPrincipal;

  ItemDataNotifier _provider = ItemDataNotifier();
  ItemDataNotifier get provider => _provider;

  Stream<List<Item>> get streamSubItens => dados.streamSubItens;
  int filtrar(Map<String, dynamic> filtros) => dados.filtrar(filtros);

  void sort<T>(
    Comparable<T> Function(Item item) getField,
    int colIndex,
    bool ascending,
    ItensDataTableSource _src,
    ItemDataNotifier _provider,
  ) {
    _src.sort<T>(getField, ascending);
    _provider.sortAscending = ascending;
    _provider.sortColumnIndex = colIndex;
  }

  close() => dados.close();
}

class ItemDataNotifier {
  bool? sortAscending;
  int? sortColumnIndex;
}
