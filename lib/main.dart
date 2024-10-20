import 'package:flutter/material.dart';
import 'pagina_principal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main(){
  runApp(MicrodadosEnem());
}

class MicrodadosEnem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: false),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('pt', 'BR'),
        const Locale('pt', ''),
      ],
      debugShowCheckedModeBanner: false,
      title: "Itens do Enem",
      home: PaginaPrincipal(),
    );
  }
}