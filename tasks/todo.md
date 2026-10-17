# Ingestão de dados — checklist

- [x] README, LICENSE, pyproject
- [x] baixar/__init__.py (baixar com 3 tentativas) + lastro.py (baixar, carregar, cruzar, status)
- [x] TSE: baixar/tse.py + sql/tse.sql (download real, confirmar encoding)
- [x] Receita: baixar/receita.py + sql/receita.sql (testar WAF)
- [x] Câmara: baixar/camara.py + sql/camara.sql
- [x] Senado: baixar/senado.py + sql/senado.sql
- [x] Portal: baixar/portal.py + sql/portal.sql
- [ ] PNCP: baixar/pncp.py + sql/pncp.sql
- [x] PGFN, TCU, SICONFI, IBGE
- [x] sql/cruzar.sql + tests/test_cruzar.py
- [x] status mostra tudo; commit + draft PR

## Revisão (2026-10-17)
- 27 tabelas `core` carregadas, incluindo `despesa_campanha` (12,49 mi; 1 linha de 2020 descartada por byte inválido) e `vinculo` (818 mil, 10 regras).
- Ficha completa de um deputado federal de 2022 validada por consulta direta.
- Pendente só o que depende de tempo: PNCP (API paginada) e SICONFI (uma requisição por ente e ano), ambos retomáveis.
- Draft PR: https://github.com/r-a-f-a/lastro/pull/1
