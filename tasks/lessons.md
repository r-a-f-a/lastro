
## 2026-10-16 — complicação demais na spec de ingestão
Usuário: "Precisamos criar algo mais simples, estamos complicando demais." A primeira spec tinha schema stg, manifest com sha256, typer, matriz de retentativa, amostras por fonte.
Regra: para projeto solo/open source que roda no computador do usuário, começar com um script por fonte + um SQL por fonte + um banco. Sem camadas, sem framework, sem metadados que ninguém pediu. Só adicionar quando a dor aparecer.

## 2026-10-17 — paginação por offset sem ordem estável
Lista de entes do SICONFI (ORDS) paginada com `limit/offset` voltou com 537 repetidos e 537 omitidos: o servidor não ordena entre páginas. Regra: em qualquer API paginada, conferir `len(únicos) == len(total)` e, quando houver, comparar com uma lista de referência (IBGE). Preferir uma página grande o suficiente para não paginar, e `assert not hasMore`.
