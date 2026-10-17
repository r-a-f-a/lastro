# Lastro — ingestão de dados (versão simples)

Data: 2026-10-16. Substitui a versão anterior desta spec, que tinha camadas e ferramentas demais.

## Objetivo

Baixar os dados abertos das fontes do catálogo para o computador, carregar tudo num único arquivo DuckDB e cruzar as entidades em `core.vinculo` com grau de confiança. Tudo roda com `python lastro.py <comando>` a partir de um clone do repositório público `github.com/r-a-f-a/lastro`.

Pronto quando: `python lastro.py status` mostra todas as tabelas `core` preenchidas, `cruzar` gera `core.vinculo`, e uma consulta por `sq_candidato` de qualquer deputado federal eleito em 2022 devolve a ficha completa (perfil, bens, receitas, mandato, empresas, contratos, sanções).

## Decisões

- **Um banco**: `data/lastro.duckdb`. Sem Parquet intermediário, sem schema `stg`. Cada fonte tem um `.sql` que lê os arquivos brutos direto (`read_csv`/`read_json`) e grava as tabelas `core`.
- **Um script por fonte**, só download. Nada de parsing em Python; quem tipa e limpa é o SQL.
- **Idempotência mínima**: arquivo existente com tamanho > 0 não é baixado de novo. Para refazer, apague o arquivo.
- **Sem framework de CLI**, sem manifest, sem sha256, sem retentativa configurável. Uma função `baixar(url, destino)` com 3 tentativas fixas para erro de rede ou 5xx.
- **Escopo**: eleições 2018, 2020, 2022, 2024 (todos os cargos e UFs); demais fontes desde 2019. Receita Federal: último mês publicado. Sem chave do Portal da Transparência.
- **Licença**: código AGPL-3.0, dados derivados CC BY 4.0 (como já consta na tela "Sobre").
- URLs, formatos e encodings validados estão em `docs/fontes-validacao.md`; a spec não os repete.

## Layout

```
lastro.py            baixar <fonte|tudo> | carregar <fonte|tudo> | cruzar | status
baixar/
  __init__.py        baixar(url, destino, headers=None) com 3 tentativas
  tse.py camara.py senado.py receita.py portal.py pncp.py pgfn.py tcu.py siconfi.py ibge.py
sql/
  tse.sql camara.sql ... ibge.sql   raw -> core, um por fonte, CREATE OR REPLACE
  cruzar.sql                        core.vinculo
tests/test_cruzar.py               casos de homônimo, cpf6 igual, contrato antes da doação
data/                              gitignored: raw/<fonte>/... e lastro.duckdb
pyproject.toml                     duckdb, httpx; dev: pytest
README.md                          como rodar, ordem das fontes, tempo e espaço esperados
```

Cada `baixar/<fonte>.py` expõe `main()`: monta a lista de URLs do escopo e chama `baixar()` para cada uma, gravando em `data/raw/<fonte>/`. APIs paginadas (PNCP, Senado, SICONFI, TCU) gravam uma página por arquivo JSON e param quando a página vem vazia.

`lastro.py carregar <fonte>` executa `sql/<fonte>.sql` no DuckDB, com `data/raw/<fonte>` disponível como variável `raw`. `lastro.py cruzar` executa `sql/cruzar.sql`. `status` lista contagem por tabela `core` e data do arquivo mais recente de cada fonte.

## Modelo (schema `core`)

pessoa, candidatura, bem_declarado, receita_campanha, despesa_campanha, cassacao, votos_munzona, empresa, estabelecimento, socio, mandato, presenca, votacao, voto, proposicao, autoria, despesa_cota, contrato, emenda, emenda_favorecido, sancao, sancao_tcu, divida_ativa, territorio, financas_municipio, vinculo. Tabelas `rf_*` guardam os domínios da Receita (CNAE, natureza jurídica, qualificação de sócio, município).

Filiação partidária ficou de fora: o TSE só publica o perfil agregado dos filiados, não a lista nominal.

Colunas em snake_case, tipadas no SQL. Chaves derivadas: `cpf6` (6 dígitos centrais) e `nome_norm` (maiúsculo, sem acento, sem DA DE DO DAS DOS E). CPF completo só existe em `pessoa`; nunca sai dela em export.

`vinculo`: origem_tipo, origem_id, destino_tipo, destino_id, tipo, grau (alta | media | possivel), regra, fonte, coletado_em, evidencia.

## Regras de cruzamento (`sql/cruzar.sql`)

| regra | chave | grau |
|---|---|---|
| doador_fornecedor | CNPJ doador = CNPJ fornecedor | alta |
| empresa_sancao | CNPJ | alta |
| empresa_contrato | CNPJ | alta |
| pessoa_sancao_cpf | CPF completo (TCU) | alta |
| pessoa_mandato_cpf | CPF completo | alta |
| pessoa_socio | cpf6 + nome_norm | media |
| pessoa_sancao_cpf6 | cpf6 + nome_norm (CEAF) | media |
| pessoa_divida_cpf6 | cpf6 + nome_norm (PGFN) | media |
| pessoa_mandato_nome | nome_norm + UF + partido | possivel |
| autor_emenda | nome_norm do autor | possivel |

Nome sozinho nunca gera vínculo. Se o TSE mascarar o CPF em 2022/2024, as regras por CPF completo caem para cpf6 e grau média.

## Ordem de execução e tamanho esperado

TSE → Receita → Câmara → Senado → Portal (CEIS, CNEP, CEPIM, CEAF, emendas) → PNCP → PGFN → TCU → SICONFI → IBGE → cruzar. Receita ~8 GB zipados, PNCP de 2 a 6 h de API; o resto em minutos. Cada fonte roda sozinha, então dá para começar pelas rápidas.

## Riscos

- Receita pode bloquear mesmo com User-Agent de navegador; plano B é o espelho mensal do Brasil.io.
- Encodings do TSE e da Receita são hipóteses até o primeiro arquivo real; o `.sql` de cada fonte ajusta.
- PNCP sem dump: só API paginada, lenta.
