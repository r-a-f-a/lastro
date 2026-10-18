# Lastro

Transparência de candidatos a partir de dados abertos brasileiros. Cada informação traz fonte, data de coleta e, quando a ligação não é por chave exata, o grau de confiança (alta, média, possível). **Mostra, não julga.**

Este repositório contém a ingestão: scripts que baixam os dados abertos para o seu computador, um banco [DuckDB](https://duckdb.org) com o modelo canônico e as regras de cruzamento entre candidatos, empresas, contratos e sanções.

## Como rodar

Requer Python 3.11+ e [uv](https://docs.astral.sh/uv/).

```bash
uv sync
uv run lastro.py baixar tse        # baixa para data/raw/tse/
uv run lastro.py carregar tse      # grava as tabelas core no data/lastro.duckdb
uv run lastro.py baixar tudo       # todas as fontes, na ordem abaixo
uv run lastro.py carregar tudo
uv run lastro.py cruzar            # gera core.vinculo
uv run lastro.py status            # contagem por tabela e data de cada fonte
```

Arquivo já baixado não é baixado de novo. Para refazer, apague o arquivo em `data/raw/<fonte>/`.

## Fontes e escopo

| Fonte | O que | Recorte | Tamanho |
|---|---|---|---|
| TSE | candidaturas, bens, receitas e despesas de campanha, filiação, cassações, votação | eleições 2018, 2020, 2022, 2024 | ~6 GB |
| Receita Federal | empresas, estabelecimentos, sócios | último mês publicado | ~8 GB zipados |
| Câmara | deputados, presença, votações, proposições, cota parlamentar | 2019 em diante | ~2 GB |
| Senado | senadores, votações, CEAPS | legislaturas 56 e 57 | ~200 MB |
| Portal da Transparência | CEIS, CNEP, CEPIM, CEAF, emendas parlamentares | coleta do dia; emendas desde 2019 | ~500 MB |
| PNCP | contratos públicos | 2021 em diante, por API paginada | horas de download |
| PGFN | dívida ativa da União | 3 arquivos | ~2 GB |
| TCU | responsáveis inabilitados, inidôneos, contas irregulares | lista atual | pequeno |
| SICONFI | receitas orçamentárias anuais (DCA Anexo I-C) de cada município e estado | 2019 em diante, uma requisição por ente e ano | ~2 GB, horas |
| IBGE | municípios, população Censo 2022 | atual | pequeno |

URLs, formatos e encodings validados estão em [`docs/fontes-validacao.md`](docs/fontes-validacao.md). O desenho está em [`docs/superpowers/specs/2026-10-16-ingestao-dados-design.md`](docs/superpowers/specs/2026-10-16-ingestao-dados-design.md). O catálogo completo das fontes, incluindo as que ainda não entram, está no arquivo `Catálogo de Dados Públicos`.

## Como os dados se ligam

`sql/cruzar.sql` gera `core.vinculo`. Cada vínculo tem a regra que o gerou e um grau:

- **alta**: chave exata (CNPJ, CPF completo).
- **média**: seis dígitos centrais do CPF + nome normalizado.
- **possível**: nome normalizado + UF + partido, ou nome do autor de emenda.

Nome sozinho nunca gera vínculo. CPF completo só existe na tabela `core.pessoa` e nunca sai dela.

O TSE publica o CPF completo dos candidatos de 2018, 2020 e 2022 (na consulta de candidatos ou na prestação de contas), mas mascara todos os CPFs de 2024. Candidatos que só concorreram em 2024 ainda não entram em `core.pessoa` nem nos vínculos por CPF. A Câmara não publica CPF no cadastro de deputados; ele vem da cota parlamentar. O Senado não publica CPF, então senadores só se ligam a candidaturas por nome, UF e partido (grau possível).

## Licença

Código: [AGPL-3.0](LICENSE). Dados derivados: CC BY 4.0. Os dados de origem seguem as licenças dos órgãos que os publicam.
