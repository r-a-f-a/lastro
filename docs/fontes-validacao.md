# Fontes de dados abertos — validação de URLs (out/2026)

Legenda: **OK** = confirmado por fetch nesta sessão; **~** = parcialmente confirmado; **NC** = não confirmado (hipótese + URL tentada).
Encoding/separador raramente são publicados nos portais; quando não lidos de um arquivo real, estão marcados como hipótese.

## 1. TSE — Repositório de Dados Eleitorais (OK)
- Base: `https://cdn.tse.jus.br/estatistica/sead/odsele/{pasta}/{arquivo}_{ano}.zip`; catálogo CKAN em `https://dadosabertos.tse.jus.br/dataset/{slug}` e API `/api/3/action/package_show?id={slug}`.
- Candidatos (slug `candidatos-{ano}`): `consulta_cand/consulta_cand_{ano}.zip`, `bem_candidato/bem_candidato_{ano}.zip`, `motivo_cassacao/motivo_cassacao_{ano}.zip`, `consulta_cand_complementar/...`, `consulta_coligacao/...`, `consulta_vagas/...` (confirmado 2022 e 2024; 2018/2020 seguem o mesmo padrão — ~). Arquivo nacional, com 1 CSV por UF dentro do zip (`consulta_cand_{ano}_{UF}.csv`, `_BRASIL.csv` consolidado — ~).
- Prestação de contas (slug `prestacao-de-contas-eleitorais-{ano}`; 2022 tem slug anômalo `dadosabertos-tse-jus-br-dataset-prestacao-de-contas-eleitorais-2022`): `prestacao_contas/prestacao_de_contas_eleitorais_candidatos_{ano}.zip` e `..._orgaos_partidarios_{ano}.zip` (confirmado 2018/2022/2024). Os CSVs `receitas_candidatos_{ano}_{UF}.csv`, `despesas_contratadas_candidatos_{ano}_{UF}.csv`, `despesas_pagas_...` ficam DENTRO do zip de candidatos (nomes internos — ~, não listados no portal). Também `fefc_fp/fefc_fp_{ano}.zip`, `CNPJ_campanha_{ano}.zip`.
- Resultados (slug `resultados-{ano}`): `votacao_candidato_munzona/votacao_candidato_munzona_{ano}.zip` (nacional, sem UF); por seção: `votacao_secao/votacao_secao_{ano}_{UF}.zip`.
- Filiação: `filiacao_partidaria/perfil_filiacao_partidaria.zip` (único, todos os partidos; slug `delegados-partidarios`). Não há recorte por UF/partido na URL.
- Formato: zip com CSV + `leiame.pdf`. Separador `;`, aspas em todos os campos, encoding **latin1/ISO-8859-1** (electionsBR documenta como "original encoding"; não lido de arquivo nesta sessão). Sem chave. Listagem de diretório `cdn.tse.jus.br/.../consulta_cand/` retorna 403 (não navegável). Tamanhos não exibidos no portal.

## 2. Receita Federal — CNPJ (~)
- URL oficial de referência: `https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{AAAA-MM}/`. **NC nesta sessão**: raiz devolve 403 e pastas/arquivos 404 via fetch não-browser (tentado `2025-09/`, `2026-09/`, `2025-09/Cnaes.zip`); espelho antigo `dadosabertos.rfb.gov.br/CNPJ/dados_abertos_cnpj/` recusou conexão. Provável WAF bloqueando user-agent; validar com browser/curl.
- Nomes (layout oficial + repositórios da comunidade): `Empresas0..9.zip`, `Estabelecimentos0..9.zip`, `Socios0..9.zip`, `Simples.zip`, `Cnaes.zip`, `Qualificacoes.zip`, `Naturezas.zip`, `Municipios.zip`, `Motivos.zip`, `Paises.zip` (37 zips).
- Layout (PDF oficial `gov.br/receitafederal/dados/cnpj-metadados.pdf`, lido): sem cabeçalho, separador `;`, campos conforme tabelas Empresas/Estabelecimentos/Simples/Sócios/domínios; CPF de sócio mascarado (`***nnnnnn**`); CNAE secundária = lista separada por vírgula no campo.
- Encoding: declarado ISO-8859-1, na prática **cp1252**; aspas duplas escapadas por duplicação (`""`). Tamanho: ~8 GB compactado / ~27 GB CSV (relato comunitário set/2026). Atualização mensal. Atenção: CNPJ alfanumérico a partir de jul/2026.

## 3. Câmara dos Deputados (OK)
- Dumps: `https://dadosabertos.camara.leg.br/arquivos/{colecao}/{fmt}/{colecao}-{ano}.{fmt}` (anuais) ou `{colecao}.{fmt}` (únicos); fmt ∈ csv, json, xml, xlsx, ods. Coleções: `deputados`, `proposicoes`, `proposicoesAutores`, `proposicoesTemas`, `votacoes`, `votacoesVotos`, `votacoesOrientacoes`, `votacoesObjetos`, `eventos`, `eventosPresencaDeputados`, `eventosOrgaos`, `frentes`, `frentesDeputados`, `orgaos`, `orgaosDeputados-L{legislatura}`.
- CEAP: `https://www.camara.leg.br/cotas/Ano-{ano}.csv.zip` (também `.json.zip`, `.xml.zip`; confirmado Ano-2008 → `Ano-2008.csv` interno).
- Formato CSV lido: `;`, todos os campos entre aspas, **UTF-8 com BOM**, com cabeçalho. `eventosPresencaDeputados-2026.csv` = 9,1 MB (jan–out); colunas `idEvento;uriEvento;dataHoraInicio;idDeputado;uriDeputado`. 2024 > 10 MB.
- API v2 presença: não há endpoint "presença" direto; usar `GET /api/v2/eventos?dataInicio&dataFim[&codTipoEvento]` (paginado, links next/last) e `GET /api/v2/eventos/{id}/deputados` (participantes do evento; sessões deliberativas = presença). Sem chave; `itens` máx. 100.

## 4. Senado Federal (OK)
- Legislativo: `https://legis.senado.leg.br/dadosabertos` (OpenAPI em `/v3/api-docs`). Senadores: `/senador/lista/atual`, `/senador/lista/legislatura/{n}`. Votações: `/votacao?dataInicio&dataFim` (máx. 1 ano por consulta; endpoints `/plenario/lista/votacao/...` deprecados). Formatos via Accept ou sufixo `.json/.xml/.csv`. Sem chave; >10 req/s → 429.
- CEAPS: **o caminho `senado.gov.br/transparencia/LAI/verba/{ano}.csv` redireciona para `senado.leg.br/...` e devolve 404 — descontinuado**. Atual: `GET https://adm.senado.gov.br/adm-dadosabertos/api/v1/senadores/despesas_ceaps/{ano}/csv` (JSON sem `/csv`; campos `codSenador, nomeSenador, mes, fornecedor, data, valorReembolsado`). Sem chave. Separador/encoding do CSV não lidos (hipótese: `;`, UTF-8).

## 5. Portal da Transparência — download de dados (OK)
- Padrão: `https://portaldatransparencia.gov.br/download-de-dados/{dataset}/{periodo}` → 302 para `https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/{dataset}/{periodo}_{Nome}.zip`.
- Confirmados: `ceis/AAAAMMDD` → `AAAAMMDD_CEIS.zip` (3,2 MB, contém `AAAAMMDD_CEIS.csv`); `cnep/AAAAMMDD` → `_CNEP.zip`; `cepim/AAAAMMDD` → `_CEPIM.zip`; `ceaf/AAAAMMDD` → `_CEAF.zip`; `despesas-execucao/AAAAMM` → `AAAAMM_Despesas.zip`; `compras/AAAAMM` → `AAAAMM_Compras.zip` (contratos); `emendas-parlamentares/UNICO` → `EmendasParlamentares.zip`.
- Sem chave para dumps (a API REST `api.portaldatransparencia.gov.br` exige `chave-api-dados`). Dicionários em `/pagina-interna/6034xx-dicionario-de-dados-*` (páginas respondem 405 a fetch). Formato: CSV `;`, encoding **latin1/cp1252** (hipótese, consistente com bradata; não lido). Sanções: snapshot diário por data.

## 6. PNCP (OK / ~)
- API: `https://pncp.gov.br/api/consulta/v1/contratos?dataInicial=AAAAMMDD&dataFinal=AAAAMMDD&pagina=N[&tamanhoPagina=10..500][&cnpjOrgao]`; também `/v1/contratos/atualizacao` (por data de atualização). Resposta: `data[], totalRegistros, totalPaginas, numeroPagina, paginasRestantes`. Spec declara bearer JWT mas endpoints de consulta são públicos (sem chave). OpenAPI: `/api/consulta/v3/api-docs`.
- Dump CSV: não existe no PNCP. Alternativa oficial: dados.gov.br "Compras Públicas do Governo Federal" (Compras.gov.br) com CSVs `comprasGOV-{diario|mensal|anual}-VW_FT_PNCP_COMPRA-latest.csv`, `..._COMPRA_ITEM-latest.csv`, `VW_DM_PNCP_ITEM_RESULTADO-latest.csv` (separador `,`, UTF-8; anos anteriores em índice de diretório por ano). Cobre contratações, não "contratos" strictu sensu.

## 7. PGFN (OK)
- `https://dadosabertos.pgfn.gov.br/` (índice simples): `Dados_abertos_FGTS.zip`, `Dados_abertos_Nao_Previdenciario.zip`, `Dados_abertos_Previdenciario.zip`; histórico em `/{AAAA}_trimestre_{0N}/` (2020_trimestre_01 … 2026_trimestre_02) com os mesmos três arquivos. Dicionário `.xlsx` na página gov.br/pgfn (dados-abertos). Tamanhos/encoding não exibidos (hipótese: CSV `;`, latin1, zip de centenas de MB). Sem chave.

## 8. TCU (~)
- `dados.tcu.gov.br` **não resolve DNS** — migrou para `https://sites.tcu.gov.br/dados-abertos/`. Listas em `/dados-abertos/inidoneos-irregulares` (dicionário em `.../dicionario-dados.html`): inabilitados, licitantes inidôneos, contas irregulares, contas irregulares c/ implicação eleitoral. As páginas apontam para SPA `certidoes.apps.tcu.gov.br/lista-*`; **link CSV direto não encontrado**.
- API pública (sem chave): `POST https://certidoes.apps.tcu.gov.br/api/publico/{responsaveis-inabilitados|responsaveis-inidoneos|responsaveis-contas-irregulares|responsaveis-fins-eleitorais}` com body JSON opcional `{parteNome,cpf,cnpj,uf,municipio}`; body vazio retorna a lista completa (hipótese). Campos: Nome, CPF/CNPJ, UF, Município, Processo, Acórdão, Trânsito em julgado, Data final da sanção.

## 9. SICONFI / Tesouro (OK)
- ORDS: `https://apidatalake.tesouro.gov.br/ords/siconfi/tt/{dca|rreo|rgf|entes|anexos-relatorios|msc_*}`. Confirmados: `entes` (cod_ibge, ente, uf, esfera, populacao, cnpj); `dca?an_exercicio&id_ente&no_anexo=DCA-Anexo I-AB`; `rreo?an_exercicio&nr_periodo&co_tipo_demonstrativo=RREO&id_ente&no_anexo=RREO-Anexo 01`; `rgf?an_exercicio&in_periodicidade=Q&nr_periodo&co_tipo_demonstrativo=RGF&co_poder=E&id_ente`. JSON `{items,hasMore,limit,offset,count,links}`, limit padrão 5000, paginar por `offset`. Sem chave; `/docs/siconfi` é SPA (não legível por fetch).
- FPM: Tesouro Transparente CKAN `https://www.tesourotransparente.gov.br/ckan/dataset/transferencias-constitucionais-para-municipios` → CSVs mensais `transferenciamensalmunicipios{AAAAMM}.csv.csv` (~4–7 MB) e anuais (~50 MB), via `/resource/{id}/download/{file}`. API alternativa `apiapex.tesouro.gov.br/aria/v1/transferencias_constitucionais/custom` (retornou 500 na raiz; usada pelo pacote tesouror).

## 10. IBGE (OK)
- Localidades: `https://servicodados.ibge.gov.br/api/v1/localidades/municipios` (lista completa; `?view=nivelado` achata; `/municipios/{id}` confirmado). Campos: id, nome, microrregiao→mesorregiao→UF→regiao, regiao-imediata→regiao-intermediaria.
- População Censo 2022: agregado **4714**, variável **93**: `https://servicodados.ibge.gov.br/api/v3/agregados/4714/periodos/2022/variaveis/93?localidades=N6[all]` (confirmado com `N6[3550308]` → 11.451.999). Também var. 6318 (área) e 614 (densidade). Sem chave; sem paginação.

## 11. Transferegov (~)
- Portal antigo `api.transferegov.gov.br` não resolve; `api.transferegov.gestao.gov.br` (PostgREST) **desativa em 2026-08-31**. Atual: `https://api-publica.transferegov.gestao.gov.br/{especiais|fundoafundo|parcerias|ted}` com docs em `/{modulo}/docs` (Swagger, SPA). Paginação por página: máx. 200 linhas (especiais, parcerias) e 1000 (fundoafundo, ted). Sem chave.
- Dump CSV: só para Discricionárias/Legais (SICONV) em `https://api-publica.transferegov.gestao.gov.br/downloads`. Para Transferências Especiais (emendas Pix) **não há dump confirmado** — usar API `especiais` (tabelas plano_acao_especial, programa_especial, empenho/execução — nomes não confirmados).
