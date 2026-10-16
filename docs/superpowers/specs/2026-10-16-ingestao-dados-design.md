# Ingestão de dados do Lastro — design

Data: 2026-10-16 · Autor: Rafael Rodrigues com Claude · Status: aprovado em conversa, aguardando revisão do texto

## 1. Objetivo

Alimentar as fichas do Lastro com dados reais, cruzando as fontes oficiais pelas chaves da matriz do catálogo (`Catálogo de Dados Públicos — Plataforma de Transparência de Candidatos.md`) e guardando um grau de confiança por vínculo. Entrega desta rodada: extratores (download), estrutura do banco (DuckDB) e carga completa do escopo da seção 3, mais as regras de cruzamento da seção 6.

Sucesso: o comando `lastro status` mostra todas as tabelas `core` preenchidas, `lastro cruzar` produz a tabela `vinculo` com os três graus, e uma consulta por `sq_candidato` de qualquer deputado federal eleito em 2022 devolve candidaturas, bens, receitas, mandato (presença, votações, cota), empresas, contratos, sanções e emendas.

## 2. Decisões já tomadas

| Decisão | Escolha | Motivo |
|---|---|---|
| Banco | DuckDB em arquivo único + exportação Parquet | Zero infra, lê CSV zipado direto, ingere a Receita em minutos. Postgres só se nascer escrita concorrente. |
| Abrangência | Eleições 2018, 2020, 2022, 2024; todos os cargos e UFs; demais fontes desde 2019 | Pedido do usuário. |
| Chave do Portal da Transparência | Não nesta rodada | Só dumps públicos. O cliente da API fica fora do escopo. |
| Abordagem | ELT: Python só baixa; carga e cruzamento são SQL no DuckDB | Menor código possível. Sem framework de pipeline. |
| Base dos Dados / BigQuery | Não usar | Exige billing no GCP e não cobre PNCP, PGFN e sanções. |

## 3. Escopo da carga

Fonte, caminho validado (`docs/fontes-validacao.md`) e recorte:

| Fonte | Caminho | Recorte |
|---|---|---|
| TSE | `cdn.tse.jus.br/estatistica/sead/odsele/{pasta}/{arquivo}_{ano}.zip` | `consulta_cand`, `bem_candidato`, `motivo_cassacao`, `votacao_candidato_munzona`, `prestacao_de_contas_eleitorais_candidatos` (receitas e despesas dentro do zip), `perfil_filiacao_partidaria` (único). Anos 2018, 2020, 2022, 2024. |
| Receita CNPJ | `arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{AAAA-MM}/` | 37 zips do mês mais recente: Empresas, Estabelecimentos, Sócios, Simples e tabelas de domínio. Exige User-Agent de navegador. |
| Câmara | `dadosabertos.camara.leg.br/arquivos/{colecao}/csv/{colecao}-{ano}.csv` e `camara.leg.br/cotas/Ano-{ano}.csv.zip` | `deputados` (único), `proposicoes`, `proposicoesAutores`, `votacoes`, `votacoesVotos`, `votacoesOrientacoes`, `eventos`, `eventosPresencaDeputados`, `frentesDeputados`, CEAP. Anos 2019 a 2026. API v2 `/deputados/{id}` só para CPF e situação atual. |
| Senado | `legis.senado.leg.br/dadosabertos` e `adm.senado.gov.br/adm-dadosabertos/api/v1/senadores/despesas_ceaps/{ano}/csv` | Senadores das legislaturas 56 e 57, votações por ano (limite de um ano por consulta), CEAPS 2019 a 2026. |
| Portal da Transparência | `portaldatransparencia.gov.br/download-de-dados/{dataset}/{periodo}` (302 para o zip da CGU) | CEIS, CNEP, CEPIM, CEAF do dia da coleta; `compras/AAAAMM` de 2019-01 a 2026-10; `emendas-parlamentares/UNICO`. |
| PNCP | `pncp.gov.br/api/consulta/v1/contratos?dataInicial&dataFinal&pagina&tamanhoPagina=500` | Contratos de 2021-01 a 2026-10, janelas mensais, JSON bruto guardado por página. |
| PGFN | `dadosabertos.pgfn.gov.br/` | Três zips atuais (FGTS, Previdenciário, Não Previdenciário). |
| TCU | `POST certidoes.apps.tcu.gov.br/api/publico/{lista}` com body `{}` | `responsaveis-inabilitados`, `responsaveis-inidoneos`, `responsaveis-contas-irregulares`, `responsaveis-fins-eleitorais`. |
| SICONFI | `apidatalake.tesouro.gov.br/ords/siconfi/tt/{entes|dca|rreo}` | `entes` completo; DCA Anexo I-AB e RREO Anexo 01 de 2019 a 2025 para todos os municípios, paginado por `offset`. |
| IBGE | `servicodados.ibge.gov.br/api/v1/localidades/municipios` e `api/v3/agregados/4714/periodos/2022/variaveis/93?localidades=N6[all]` | Municípios e população do Censo 2022. |

Fora desta rodada: Transferegov, Tesouro Transparente (FPM), Querido Diário, assembleias, câmaras municipais, TCEs, CNJ improbidade, DataJud, consultas processuais com CAPTCHA, verba de gabinete da Câmara, API do Portal da Transparência.

## 4. Layout do repositório

```
lastro/
  __init__.py
  cli.py            # typer: baixar, carregar, cruzar, status
  lake.py           # download idempotente, manifest, SHA-256
  db.py             # conexão DuckDB, execução de arquivos .sql, asserts
  fontes/
    tse.py camara.py senado.py receita.py portal.py pncp.py pgfn.py tcu.py siconfi.py ibge.py
  sql/
    raw_<fonte>.sql   # um por fonte: schema raw e stg
    core.sql          # modelo canônico
    cruzar.sql        # regras de vínculo
tests/
  amostras/<fonte>/   # arquivos pequenos reais, truncados a ~50 linhas
  test_<fonte>.py test_cruzar.py
pyproject.toml        # uv; deps: duckdb, httpx, typer; dev: pytest
.env.example
data/                 # gitignored: raw/, lastro.duckdb, parquet/
```

Cada módulo em `fontes/` expõe só `arquivos(params) -> list[Arquivo]` (URL, caminho destino, cabeçalhos, método, body) e, quando a fonte é API paginada, um gerador `paginas(params)`. O download em si é um único `lake.baixar(arquivo)`. Nenhum módulo de fonte escreve no banco.

## 5. Data lake

- `data/raw/<fonte>/<AAAA-MM-DD>/<arquivo>` guarda cada download como veio. APIs paginadas gravam um JSON por página, nome `<recurso>_<parametros>_p<NNNN>.json`.
- `manifest.json` na pasta da coleta: lista de `{arquivo, url, bytes, sha256, baixado_em, http_status}`. Escrito ao final de cada arquivo, não ao final da coleta, para sobreviver a interrupções.
- Idempotência: `baixar` pula arquivo cujo caminho existe com o mesmo `Content-Length` informado pelo servidor; sem `Content-Length`, pula se existe e tem mais de 0 bytes. Flag `--forcar` rebaixa.
- Retentativa: 3 tentativas com espera 2, 8 e 30 s em erro de rede ou 5xx. 4xx e 403 falham na hora com URL e status no erro. Nunca há fallback silencioso.
- Receita e Portal da Transparência recebem `User-Agent: Mozilla/5.0 (compatible; Lastro/0.1)`.
- Senado: no máximo 5 requisições por segundo.

## 6. Modelo de dados

Três schemas no `data/lastro.duckdb`.

**`raw`.** Uma tabela por tipo de arquivo, todas as colunas `VARCHAR` com o nome original da fonte, mais `coletado_em DATE` e `arquivo_origem VARCHAR`. Carga por `read_csv` direto do zip (`zip://`) ou do CSV, com `header`, `delim`, `encoding` e `quote` fixados por fonte. JSON de API via `read_json`. `CREATE OR REPLACE` por fonte e ano: recarregar substitui.

**`stg`.** Mesmas linhas, tipos corrigidos (datas, numéricos com vírgula decimal, CNPJ com 14 dígitos, CPF mascarado normalizado para `***NNNNNN**`), nomes em `snake_case`, colunas derivadas `cpf6` (seis dígitos centrais) e `nome_norm` (maiúsculas, sem acento, sem partículas DA/DE/DO/DAS/DOS/E).

**`core`.** O modelo canônico, uma entidade por chave da matriz:

| Tabela | Chave | Origem |
|---|---|---|
| `pessoa` | `pessoa_id` (surrogate); atributos `cpf`, `cpf6`, `nome`, `nome_norm`, `nascimento` | TSE; sócios da Receita entram como pessoa sem CPF completo |
| `candidatura` | `sq_candidato`, `ano` | TSE consulta_cand, com situação, resultado, votos, partido, cargo, UF, município |
| `bem_declarado`, `receita_campanha`, `despesa_campanha` | `sq_candidato`, `ano`, sequência | TSE |
| `filiacao`, `cassacao` | `pessoa_id` / `sq_candidato` | TSE |
| `empresa` | `cnpj_basico` (8) e `cnpj` (14) em `estabelecimento` | Receita |
| `socio` | `cnpj_basico`, `nome_norm`, `cpf6` | Receita |
| `mandato` | `mandato_id` (casa + id), `pessoa_id` quando ligado | Câmara, Senado |
| `presenca`, `votacao`, `voto`, `proposicao`, `autoria`, `despesa_cota` | `mandato_id` | Câmara, Senado |
| `contrato` | `fonte`, `id_na_fonte`; `cnpj_fornecedor`, `cnpj_orgao`, valor, vigência | PNCP, Portal compras |
| `emenda` | `codigo_emenda`; autor (nome e código), beneficiário (IBGE ou CNPJ), empenhado, pago | Portal |
| `sancao` | `fonte`, `id_na_fonte`; `cpf6` ou `cnpj`, tipo, início, fim, processo | CEIS, CNEP, CEPIM, CEAF, TCU, PGFN |
| `territorio` | `codigo_ibge` | IBGE, SICONFI entes |
| `financas_municipio` | `codigo_ibge`, `ano`, conta | SICONFI DCA e RREO |
| `vinculo` | `vinculo_id`; `origem_tipo`, `origem_id`, `destino_tipo`, `destino_id`, `tipo`, `grau`, `regra`, `fonte`, `coletado_em`, `evidencia` | `cruzar.sql` |

Toda tabela `core` carrega `fonte` e `coletado_em`. CPF completo nunca sai de `pessoa`; as demais tabelas e a exportação Parquet só levam `cpf6`.

## 7. Regras de cruzamento

Cada regra é um `INSERT INTO core.vinculo ... SELECT` nomeado em `cruzar.sql`. `cruzar` apaga e recria a tabela inteira.

| Regra | Liga | Chave | Grau |
|---|---|---|---|
| `doador_fornecedor` | receita_campanha → contrato | CNPJ do doador = CNPJ do fornecedor, contrato posterior à doação | alta |
| `empresa_sancao` | empresa → sancao | CNPJ exato | alta |
| `empresa_contrato` | empresa → contrato | CNPJ exato | alta |
| `pessoa_sancao_cpf` | pessoa → sancao | CPF completo (TCU) | alta |
| `pessoa_mandato_cpf` | pessoa → mandato | CPF do perfil da API da Câmara = CPF do TSE | alta |
| `pessoa_socio` | pessoa → socio | `cpf6` igual e `nome_norm` igual | média |
| `pessoa_sancao_cpf6` | pessoa → sancao (PGFN, CEAF) | `cpf6` igual e `nome_norm` igual | média |
| `pessoa_mandato_nome` | pessoa → mandato (Senado, Câmara sem CPF) | `nome_norm` igual, mesma UF e partido na eleição | possível |
| `autor_emenda` | mandato → emenda | nome normalizado do autor igual ao do parlamentar | possível |
| `socio_bem` | reforço: `pessoa_socio` cujo candidato declara "quotas" ou "ações" da mesma razão social em `bem_declarado` | texto do bem contém `nome_norm` da empresa | mantém média, grava evidência |

Só nome, sem CPF e sem UF, nunca gera vínculo. Homônimos com `cpf6` igual e `nome_norm` igual geram um vínculo por sócio candidato, cada um em "média", como manda o catálogo.

## 8. CLI

```
lastro baixar <fonte> [--ano N] [--mes AAAA-MM] [--forcar]   # uma fonte ou "tudo"
lastro carregar <fonte>                                     # raw + stg + core da fonte
lastro cruzar                                               # recria core.vinculo
lastro exportar                                             # Parquet por tabela core em data/parquet/
lastro status                                               # linhas por tabela e última coleta
```

`baixar tudo` segue a ordem do catálogo: TSE, Receita, Câmara, Senado, Portal, PNCP, TCU, PGFN, SICONFI, IBGE. Cada comando termina com código de saída diferente de zero em qualquer erro.

## 9. Erros e verificação

- Carga de cada fonte roda em uma transação; erro desfaz tudo da fonte.
- Cada `sql/raw_<fonte>.sql` termina com asserts via `db.assert_sql`: contagem mínima por tabela, unicidade da chave em `core`, zero `NULL` nas chaves. Falha derruba a carga com a consulta que falhou.
- Testes `pytest` rodam a carga completa sobre `tests/amostras/` em um DuckDB em memória, mais `test_cruzar.py` com um conjunto mínimo que inclui: homônimo com `cpf6` diferente (não liga), homônimo com `cpf6` igual (liga em média), doador que virou fornecedor antes da doação (não liga).
- Amostras são as primeiras ~50 linhas de arquivos reais, com CPFs e nomes de terceiros substituídos por valores fictícios antes de commitar.

## 10. Riscos

- Receita pode bloquear mesmo com User-Agent; plano B é o espelho mensal do Brasil.io. Decidir no primeiro download real.
- TSE pode mascarar CPF em 2022 e 2024; se mascarar, `pessoa_socio` e `pessoa_sancao_cpf6` continuam valendo e `pessoa_mandato_cpf` cai para `pessoa_mandato_nome`.
- PNCP: ~70 meses × páginas de 500; estimativa de 2 a 6 horas. Download é retomável por mês.
- Volume total bruto estimado: 25 a 40 GB; banco DuckDB estimado em 15 a 25 GB. Cabe nos 117 GB livres.
- Encoding e separador de TSE, Portal, PGFN e CEAPS são hipóteses até o primeiro arquivo real; `raw_<fonte>.sql` fixa esses valores e o teste de amostra os valida.
