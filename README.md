# itens_do_enem

Aplicativo Flutter para consulta dos itens do ENEM consumindo todos os dados
diretamente do Supabase.

## Configuração do Supabase

O aplicativo utiliza o pacote `supabase_connect` para acessar as tabelas e os
arquivos de prova hospedados no Supabase. Para executar o projeto é necessário
informar a URL do projeto e a chave pública (anon key) por meio de `dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<sua-url>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<sua-chave-anonima>
```

As mesmas variáveis devem ser informadas para builds de release ou execução de
testes.

## Dependências

- [supabase_connect](packages/supabase_connect): cliente HTTP leve para a API do
  Supabase.
- `flutter_pdfview` para renderização dos PDFs baixados do Supabase.
- `path_provider` para armazenar temporariamente os arquivos baixados.
