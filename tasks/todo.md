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
- [x] status mostra tudo (falta TSE despesas); commit + draft PR pendente
