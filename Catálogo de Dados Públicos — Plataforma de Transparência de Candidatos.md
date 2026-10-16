# Catálogo de Dados Públicos — Plataforma de Transparência de Candidatos

Oct 14, 2026 · @Rafael Rodrigues

## Visão geral

Tudo o que a plataforma precisa existe em dados abertos oficiais; o trabalho é ingestão e cruzamento, não coleta. Cinco eixos cobrem o ciclo completo: quem é o candidato, o que fez no mandato, que dinheiro público circula ao seu redor, se tem sanções e o contexto do território.

Cada ficha traz: fonte, o que entrega, formato e acesso, chave de ligação e frequência de atualização. As chaves de ligação (CPF, CNPJ, sequencial TSE, id Câmara/Senado) são o que transforma bases isoladas em um dossiê por candidato — a matriz no fim do documento mostra como elas se encadeiam.

URLs e formatos refletem o conhecimento até esta data; validar cada endpoint no início da ingestão, pois os portais mudam versão sem aviso.

## Eixo 1 — Perfil e candidaturas (TSE)

O TSE é a espinha dorsal: é a única fonte que identifica todo candidato do país com um sequencial único por eleição, ligado ao CPF.

| Fonte | O que entrega | Formato / acesso | Chave de ligação | Atualização |
| --- | --- | --- | --- | --- |
| [Repositório de Dados Eleitorais](https://dadosabertos.tse.jus.br/) | Candidatos (nome, CPF, partido, cargo, situação, grau de instrução, ocupação), bens declarados, resultados por seção/zona, filiação partidária, cassações, pesquisas registradas, eleitorado | CSV zipado por eleição e UF, 1945–2024; portal CKAN com API de catálogo | `SQ_CANDIDATO` (sequencial por eleição), `NR_CPF_CANDIDATO`, `NR_TITULO_ELEITORAL` | A cada eleição; correções pontuais entre pleitos |
| [DivulgaCandContas](https://divulgacandcontas.tse.jus.br/) | Perfil do candidato, bens, certidões, propostas de governo (PDF), situação de registro, contas de campanha | API REST JSON não documentada oficialmente (usada pelo próprio site) + CSV no repositório | `SQ_CANDIDATO`, id da eleição | Diária durante o período eleitoral |
| Prestação de contas eleitorais (no repositório) | Receitas por doador (CPF/CNPJ, origem: Fundo Especial de Financiamento de Campanha, Fundo Partidário, pessoa física, outros candidatos), despesas contratadas e pagas, fornecedores | CSV por eleição e UF | `SQ_CANDIDATO`, `NR_CPF_CNPJ_DOADOR`, `NR_CPF_CNPJ_FORNECEDOR` | Final de campanha, com retificações até julgamento |
| Prestação de contas partidárias anuais (SPCA) | Receitas e despesas dos partidos fora de campanha, inclusive Fundo Partidário | CSV e PDF | CNPJ do diretório | Anual |
| Lista de inelegíveis / Ficha Limpa | Candidatos com registro indeferido, cassados, condenados por órgão colegiado | Consulta por CPF e CSV de situação de candidatura | CPF | Contínua |
| Processos eleitorais (PJe-TSE e consulta unificada) | AIJE, AIME, representações, propaganda irregular | Consulta pública HTML; sem API aberta | CPF, número CNJ do processo | Contínua |

Pontos de atenção: o CPF vem mascarado em alguns conjuntos recentes por decisão da LGPD — o cruzamento mais seguro usa `SQ_CANDIDATO` + nome completo + data de nascimento. Bens declarados são autodeclarados e sem valor de mercado atualizado.

## Eixo 2 — Atuação parlamentar

Câmara e Senado têm as melhores APIs públicas do Estado brasileiro; o nível estadual e municipal é onde a cobertura cai.

| Fonte | O que entrega | Formato / acesso | Chave de ligação | Atualização |
| --- | --- | --- | --- | --- |
| [API Dados Abertos da Câmara v2](https://dadosabertos.camara.leg.br/swagger/api.html) | Deputados (perfil, gabinete, situação), presença em sessões, votações nominais, proposições e autoria, discursos, frentes, comissões, órgãos | REST JSON/XML/CSV, sem chave; também dumps anuais em CSV/JSON | `id` do deputado, `idLegislatura`, CPF no perfil | Diária |
| Cota Parlamentar (CEAP) — Câmara | Despesas reembolsadas por deputado, com CNPJ do fornecedor, valor, categoria e link da nota fiscal | Endpoint `/deputados/{id}/despesas` + CSV anual | `id` do deputado, CNPJ do fornecedor | Mensal |
| Verba de gabinete e secretários parlamentares — Câmara | Funcionários por gabinete, cargo e remuneração | Portal da Transparência da Câmara (HTML/CSV); sem endpoint na API v2 | Nome, matrícula | Mensal |
| [API Dados Abertos do Senado](https://legis.senado.leg.br/dadosabertos/docs/) | Senadores, matérias, autoria, votações, presença, comissões, discursos | REST JSON/XML, sem chave | `CodigoParlamentar`, CPF no perfil | Diária |
| CEAPS — Senado | Cota de atividade parlamentar dos senadores, fornecedor e documento | CSV anual no portal de transparência do Senado | `CodigoParlamentar`, CNPJ | Mensal |
| [Portal da Transparência — emendas parlamentares](https://portaldatransparencia.gov.br/emendas) | Emendas individuais, de bancada e de comissão: autor, valor empenhado/pago, beneficiário (município, entidade), ação orçamentária | API REST com chave gratuita + CSV; também SIOP e Painel do Orçamento | Nome/código do autor, CNPJ/IBGE do beneficiário | Diária |
| [Transferegov](https://www.gov.br/transferegov/) (ex-Plataforma +Brasil) | Transferências especiais ("emendas Pix"), convênios, planos de trabalho, execução | API REST + dumps CSV | CNPJ do convenente, número do convênio, autor da emenda | Diária |
| ALESP, ALERJ, ALMG e outras assembleias | Deputados estaduais, proposições, votações; ALESP tem dados abertos em XML/JSON | Varia; metade das 27 assembleias só em HTML | Nome | Irregular |
| Câmaras municipais | Vereadores, projetos, presença | Quase sempre só HTML ou PDF; SP, RJ, BH, Curitiba e Porto Alegre têm portais estruturados | Nome | Irregular |
| [Querido Diário](https://queridodiario.ok.org.br/) (Open Knowledge Brasil) | Diários oficiais municipais em texto pesquisável, com API | API REST + busca | Nome, CNPJ, texto livre | Diária, cobertura parcial dos municípios |

Para prefeitos e governadores, a atuação não é legislativa: o eixo 3 (SICONFI, Transferegov, PNCP) cumpre o papel de "o que fez no mandato".

## Eixo 3 — Dinheiro público e empresas

Aqui está o diferencial da plataforma: ligar o candidato às empresas de que é sócio e essas empresas aos contratos públicos e às doações de campanha.

| Fonte | O que entrega | Formato / acesso | Chave de ligação | Atualização |
| --- | --- | --- | --- | --- |
| [Dados abertos do CNPJ — Receita Federal](https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj) | Cadastro completo: empresas, estabelecimentos, sócios (nome, CPF mascarado, qualificação, data de entrada), CNAE, capital social, Simples/MEI | \~5 GB em CSV zipado, em cerca de 10 arquivos | CNPJ, nome do sócio + CPF mascarado (6 dígitos centrais) | Mensal |
| [Portal da Transparência — API](https://api.portaldatransparencia.gov.br/) | Contratos, licitações, convênios, servidores e remunerações, cartões corporativos, viagens, benefícios sociais, sanções, emendas | REST JSON com chave gratuita (cadastro por e-mail); dumps CSV por módulo | CNPJ, CPF mascarado, código de órgão SIAFI | Diária |
| [PNCP — Portal Nacional de Contratações Públicas](https://pncp.gov.br/) | Editais, contratos, atas de registro de preço de União, estados e municípios sob a Lei 14.133/2021 | API REST pública documentada; CSV | CNPJ do fornecedor, CNPJ do órgão | Diária; adesão obrigatória desde 2024, cobertura ainda incompleta nos municípios |
| ComprasNet / SIASG (Compras.gov.br) | Licitações e contratos federais anteriores ao PNCP e os que seguem na Lei 8.666 | API Compras.gov.br + dados abertos | CNPJ, UASG | Diária |
| [SICONFI — Tesouro Nacional](https://siconfi.tesouro.gov.br/) | Balanços, receitas e despesas de estados e municípios (DCA, RREO, RGF), limites fiscais | API REST + CSV | Código IBGE do ente | Bimestral/anual |
| [Tesouro Transparente](https://www.tesourotransparente.gov.br/) | Transferências constitucionais (FPM, FPE), dívida, precatórios | CSV e API | Código IBGE | Mensal |
| Fundo Nacional de Saúde / FNDE / Caixa | Repasses fundo a fundo para saúde e educação por município | Portais próprios com CSV | Código IBGE, CNPJ do fundo municipal | Mensal |
| Diários oficiais (DOU, DOE, DOM) | Nomeações, exonerações, contratos dispensados, aditivos | [API da Imprensa Nacional](https://www.in.gov.br/acesso-a-informacao/dados-abertos) para o DOU; Querido Diário para municípios | Nome, CNPJ | Diária |
| Portais de transparência estaduais e municipais | Contratos e folha local, fora do PNCP | Heterogêneo; ES, MG, SP e PR têm APIs razoáveis | CNPJ | Irregular |

O CPF mascarado da Receita (ex.: `***123456**`) e o CPF do TSE (quando disponível) batem pelos seis dígitos centrais; combinar com nome completo reduz homônimos, mas não elimina — todo match deve carregar um grau de confiança visível ao usuário.

## Eixo 4 — Integridade e sanções

São listas pequenas e oficiais; o valor está em cruzá-las com o quadro societário do eixo 3, não só com o CPF do candidato.

| Fonte | O que entrega | Formato / acesso | Chave de ligação | Atualização |
| --- | --- | --- | --- | --- |
| CEIS, CNEP, CEPIM, CEAF (CGU, via Portal da Transparência) | Empresas inidôneas e suspensas, punidas pela Lei Anticorrupção, entidades impedidas de receber convênios, servidores expulsos | API do Portal da Transparência + CSV | CNPJ, CPF mascarado | Diária |
| [TCU — Dados Abertos](https://dados.tcu.gov.br/) | Acórdãos, contas julgadas irregulares, lista de responsáveis inelegíveis enviada ao TSE, licitantes inidôneos, processos | API REST + CSV; pesquisa textual de jurisprudência | CPF, CNPJ, número do acórdão | Semanal/diária |
| Tribunais de Contas estaduais e municipais | Contas de prefeitos e gestores julgadas, lista de inelegíveis estadual | TCE-SP, TCE-MG, TCE-RS e TCM-SP têm dados abertos; demais em HTML/PDF | CPF, nome | Irregular |
| [DataJud — CNJ](https://www.cnj.jus.br/sistemas/datajud/api-publica/) | Metadados de processos de todos os tribunais (classe, assunto, movimentos, órgão julgador); sem nomes de partes na API pública | API pública com chave fixa divulgada pelo CNJ | Número CNJ do processo | Diária |
| Consultas processuais dos tribunais (PJe, e-SAJ, Eproc) | Partes, andamentos, decisões | HTML por tribunal; sem API unificada; CAPTCHA em vários | Nome, CPF | Contínua |
| Cadastro de Entidades Privadas Sem Fins Lucrativos Impedidas (CEPIM) | ONGs e entidades impedidas de receber recursos | API Portal da Transparência | CNPJ | Diária |
| Lista de devedores — PGFN e Dívida Ativa | Débitos inscritos em dívida ativa da União acima de R$ 1 mil | [CSV mensal da PGFN](https://www.gov.br/pgfn/pt-br/assuntos/divida-ativa-da-uniao/dados-abertos) | CPF mascarado, CNPJ | Mensal |
| Cadastro Nacional de Condenações por Improbidade (CNJ) | Condenações por improbidade administrativa e inelegibilidade | Consulta HTML + CSV | Nome, CPF | Contínua |

Sanções e processos são o conteúdo juridicamente mais sensível: mostrar sempre o status (em andamento, transitado em julgado, absolvido), a fonte e a data da consulta, e nunca inferir culpa.

## Eixo 5 — Contexto e bases já tratadas

Boa parte do trabalho de limpeza já foi feita pela comunidade cívica; usar essas bases encurta o MVP em meses.

| Fonte | O que entrega | Formato / acesso | Uso na plataforma |
| --- | --- | --- | --- |
| [Base dos Dados](https://basedosdados.org/) | TSE (candidatos, bens, receitas, resultados), CNPJ da Receita, Câmara, SICONFI, IBGE — tratados, padronizados e cruzáveis em SQL | BigQuery público + pacotes Python/R; download CSV | Camada inicial de ingestão; já resolve chaves e tipos |
| [Brasil.io](https://brasil.io/) | CNPJ e sócios, eleições, gastos diretos, diários oficiais | API REST + CSV | Validação cruzada e fallback |
| [Serenata de Amor](https://github.com/okfn-brasil/serenata-de-amor) (OKBR) | Código aberto que audita a CEAP com detecção de anomalias | Repositório GitHub (Python) | Reaproveitar regras de suspeição de reembolsos |
| [IBGE — APIs](https://servicodados.ibge.gov.br/api/docs) | Localidades, população, PIB municipal, censo | REST JSON | Normalizar municípios e dar escala a emendas (R$ per capita) |
| IPEA Data, Atlas do Desenvolvimento Humano, DataSUS, INEP | IDH, indicadores de saúde e educação por município | CSV/API | Relacionar emendas e repasses a resultados no território |
| [Radar Legislativo](https://radarlegislativo.org/), Congresso em Foco, Politicos.org.br, Ranking dos Políticos | Projetos existentes que já ranqueiam parlamentares | Sites; alguns com código aberto | Referência de produto e de critérios; evitar repetir vieses |
| Jornalismo de dados (Fiquem Sabendo, Transparência Brasil, Agência Pública) | Pedidos de LAI já respondidos, análises e bases derivadas | Sites e repositórios | Fonte de perguntas e de bases que não estão em dados abertos |

A Lei de Acesso à Informação (12.527/2011) cobre o que não está em dados abertos: via [Fala.BR](https://falabr.cgu.gov.br/) qualquer pessoa pede dados estruturados a qualquer órgão, com prazo de 20 dias.

## Matriz de cruzamentos

Quatro chaves ligam tudo; o modelo de dados deve ter uma entidade canônica por chave, com as variantes (mascarada, nome normalizado) como atributos.

| Chave | Entidade | Bases que a carregam | Cruzamento que habilita | Confiança |
| --- | --- | --- | --- | --- |
| CPF (completo ou 6 dígitos centrais) + nome | Pessoa | TSE, Receita (sócios), Portal da Transparência (servidores, sanções), TCU, PGFN, CNJ improbidade | Candidato → empresas em que é sócio → sanções e dívidas pessoais | Alta com CPF completo; média com mascarado + nome |
| CNPJ | Empresa / órgão | Receita, PNCP, ComprasNet, Portal da Transparência, TSE (doadores e fornecedores de campanha), CEIS/CNEP, CEAP/CEAPS | Empresa do candidato → contratos públicos; doador → fornecedor de campanha → contrato com o mandato | Alta (chave exata) |
| `SQ_CANDIDATO` + ano da eleição | Candidatura | TSE (candidatos, bens, receitas, despesas, resultados, DivulgaCand) | Une todos os arquivos do TSE de um pleito | Alta |
| `id` Câmara / `CodigoParlamentar` Senado | Mandato | APIs da Câmara e do Senado, CEAP/CEAPS, emendas (por nome do autor) | Candidato eleito → presença, votos, gastos, emendas | Alta dentro da casa; ligação ao TSE exige CPF ou nome + partido + UF |
| Código IBGE do município | Território | SICONFI, Tesouro, FNS/FNDE, IBGE, emendas (beneficiário), TSE (zona/município) | Emendas e repasses → indicadores locais; base eleitoral do candidato | Alta |
| Nome normalizado (sem acento, sem partícula) | Fallback | Diários oficiais, Querido Diário, assembleias, câmaras municipais, processos judiciais | Única ligação possível em fontes sem identificador | Baixa; sempre exibir como "possível" |

Regra prática: toda ligação feita por nome, ou por CPF mascarado, entra no grafo com score e nunca aparece ao cidadão como fato — aparece como "possível vínculo, confira a fonte".

## Riscos, LGPD e lacunas

O risco jurídico não está em publicar dados públicos; está em cruzá-los para formar um perfil e em qualquer linguagem que soe como julgamento.

- LGPD: candidatos e agentes públicos têm expectativa de privacidade reduzida, mas o tratamento ainda precisa de base legal (interesse legítimo ou execução de política pública via art. 7º). Documentar finalidade, evitar inferências ("suspeito", "laranja") e oferecer canal de correção.
- Sócios e doadores que não são candidatos são terceiros: exibir só o necessário para o vínculo e mascarar CPF.
- Homônimos: o Brasil tem milhões de nomes repetidos; cruzamento por nome sem CPF gera falso positivo em escala. O score de confiança da matriz acima é obrigatório na interface.
- Lacuna municipal: 5.570 municípios sem padrão de dados de câmara e prefeitura. Começar por capitais e cidades acima de 200 mil habitantes, onde PNCP, Querido Diário e portais locais cobrem mais.
- Lacuna judicial: DataJud não traz nomes de partes; processos por candidato exigem scraping tribunal a tribunal, com CAPTCHA e risco de instabilidade.
- Instabilidade das fontes: APIs governamentais mudam sem versionamento. Guardar os arquivos brutos (data lake) e registrar data de coleta em todo registro.
- Período eleitoral: a Lei 9.504 restringe pesquisas e propaganda, não dados públicos; mas mostrar "ranking" de candidatos em período eleitoral atrai questionamento no TSE — preferir fichas comparáveis a notas únicas.

### Ordem sugerida de ingestão para o MVP

1. TSE via Base dos Dados (candidatos, bens, receitas e despesas de campanha, resultados) — entidade candidato e candidatura prontas.
2. Receita CNPJ (sócios) — vínculo candidato → empresa, com score.
3. Câmara e Senado (perfil, presença, votações, CEAP/CEAPS) — "o que fez no mandato" para federais.
4. Portal da Transparência (emendas, contratos, sanções CEIS/CNEP) + PNCP — fecha o ciclo empresa → contrato público.
5. TCU e PGFN — camada de integridade.
6. SICONFI, Transferegov e IBGE — prefeitos e governadores, indicadores por território.
7. Querido Diário e assembleias — expansão para estadual e municipal, começando por SP.

Os passos 1 a 4 já entregam uma ficha completa de qualquer deputado ou senador, com cruzamento doador → fornecedor → contrato, que é o caso de uso de maior impacto público.
