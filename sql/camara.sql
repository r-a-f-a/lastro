-- Câmara: CSVs UTF-8 com BOM e ';'. $raw = data/raw/camara.
CREATE OR REPLACE MACRO camara_csv(padrao) AS TABLE
  SELECT * FROM read_csv(padrao, delim=';', header=true, quote='"', all_varchar=true, union_by_name=true);

-- Um mandato por deputado e legislatura (56 em diante). O dump não traz CPF; vem da cota parlamentar abaixo.
CREATE OR REPLACE TABLE core.mandato AS
SELECT
  'camara'                                                    AS casa,
  regexp_extract(uri, '/deputados/(\d+)', 1)::INT             AS id_parlamentar,
  nome,
  nomeCivil                                                   AS nome_civil,
  core.nome_norm(nomeCivil)                                   AS nome_norm,
  NULL::VARCHAR                                               AS cpf,
  NULL::VARCHAR                                               AS partido,
  NULL::VARCHAR                                               AS uf,
  leg                                                         AS legislatura,
  try_cast(dataNascimento AS DATE)                            AS dt_nascimento,
  nullif(ufNascimento, '')                                    AS uf_nascimento,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/deputados.csv'), unnest(range(idLegislaturaInicial::INT, idLegislaturaFinal::INT + 1)) AS t(leg)
WHERE leg >= 56;

CREATE OR REPLACE TABLE core.despesa_cota AS
SELECT
  'camara'                                                    AS casa,
  ideCadastro::INT                                            AS id_parlamentar,
  txNomeParlamentar                                           AS nome_parlamentar,
  nullif(cpf, '')                                             AS cpf,
  nuLegislatura::INT                                          AS legislatura,
  numAno::INT                                                 AS ano,
  numMes::INT                                                 AS mes,
  txtDescricao                                                AS categoria,
  txtFornecedor                                               AS fornecedor,
  regexp_replace(txtCNPJCPF, '[^0-9]', '', 'g')               AS cpf_cnpj_fornecedor,
  try_cast(datEmissao AS TIMESTAMP)::DATE                     AS data,
  try_cast(vlrDocumento AS DECIMAL(18, 2))                    AS valor_documento,
  try_cast(vlrGlosa AS DECIMAL(18, 2))                        AS valor_glosa,
  try_cast(vlrLiquido AS DECIMAL(18, 2))                      AS valor_liquido,
  nullif(urlDocumento, '')                                    AS url_documento,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/ceap-*/Ano-*.csv')
WHERE ideCadastro <> '';

-- CPF do deputado vem da cota (CEAP): mesma pessoa, mesmo id.
UPDATE core.mandato m SET cpf = d.cpf, partido = d.partido, uf = d.uf
FROM (SELECT id_parlamentar, any_value(cpf) AS cpf, arg_max(sgPartido, ano * 100 + mes) AS partido, arg_max(sgUF, ano * 100 + mes) AS uf
      FROM (SELECT ideCadastro::INT AS id_parlamentar, nullif(cpf, '') AS cpf, sgPartido, sgUF, numAno::INT AS ano, numMes::INT AS mes
            FROM camara_csv('$raw/ceap-*/Ano-*.csv') WHERE ideCadastro <> '')
      GROUP BY 1) d
WHERE m.id_parlamentar = d.id_parlamentar AND m.casa = 'camara';

CREATE OR REPLACE TABLE core.proposicao AS
SELECT
  'camara'                                                    AS casa,
  id::BIGINT                                                  AS id_proposicao,
  siglaTipo                                                   AS tipo,
  numero::INT                                                 AS numero,
  ano::INT                                                    AS ano,
  ementa,
  try_cast(dataApresentacao AS TIMESTAMP)::DATE               AS apresentada_em,
  nullif(ultimoStatus_descricaoSituacao, '')                  AS situacao,
  nullif(ultimoStatus_siglaOrgao, '')                         AS orgao_atual,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/proposicoes-*.csv');

CREATE OR REPLACE TABLE core.autoria AS
SELECT
  'camara'                                                    AS casa,
  idProposicao::BIGINT                                        AS id_proposicao,
  try_cast(idDeputadoAutor AS INT)                            AS id_parlamentar,
  nomeAutor                                                   AS nome_autor,
  tipoAutor                                                   AS tipo_autor,
  nullif(siglaPartidoAutor, '')                               AS partido,
  nullif(siglaUFAutor, '')                                    AS uf,
  proponente = '1'                                            AS proponente,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/proposicoesAutores-*.csv');

CREATE OR REPLACE TABLE core.votacao AS
SELECT
  'camara'                                                    AS casa,
  id                                                          AS id_votacao,
  try_cast(data AS DATE)                                      AS data,
  siglaOrgao                                                  AS orgao,
  descricao,
  aprovacao = '1'                                             AS aprovada,
  try_cast(votosSim AS INT)                                   AS votos_sim,
  try_cast(votosNao AS INT)                                   AS votos_nao,
  try_cast(votosOutros AS INT)                                AS votos_outros,
  try_cast(ultimaApresentacaoProposicao_idProposicao AS BIGINT) AS id_proposicao,
  nullif(ultimaApresentacaoProposicao_descricao, '')          AS proposicao,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/votacoes-*.csv');

CREATE OR REPLACE TABLE core.voto AS
SELECT
  'camara'                                                    AS casa,
  idVotacao                                                   AS id_votacao,
  deputado_id::INT                                            AS id_parlamentar,
  deputado_nome                                               AS nome_parlamentar,
  deputado_siglaPartido                                       AS partido,
  deputado_siglaUf                                            AS uf,
  voto,
  try_cast(dataHoraVoto AS TIMESTAMP)                         AS votado_em,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/votacoesVotos-*.csv');

-- Presença só em sessões deliberativas do Plenário e reuniões deliberativas de comissão.
CREATE OR REPLACE TABLE core.presenca AS
SELECT
  'camara'                                                    AS casa,
  p.idDeputado::INT                                           AS id_parlamentar,
  p.idEvento::BIGINT                                          AS id_evento,
  try_cast(p.dataHoraInicio AS TIMESTAMP)::DATE               AS data,
  e.descricaoTipo                                             AS tipo_evento,
  current_date                                                AS coletado_em
FROM camara_csv('$raw/eventosPresencaDeputados-*.csv') p
JOIN camara_csv('$raw/eventos-*.csv') e ON e.id = p.idEvento
WHERE e.descricaoTipo IN ('Sessão Deliberativa', 'Sessão Deliberativa Extraordinária', 'Reunião Deliberativa', 'Reunião Deliberativa Extraordinária');
