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
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,
      title: "Itens do Enem",
      home: PaginaPrincipal(),
    );
  }
}