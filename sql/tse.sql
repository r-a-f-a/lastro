-- TSE: CSVs cp1252 (latin1 com extras) com ';' e aspas em todos os campos. $raw = data/raw/tse.
CREATE OR REPLACE MACRO tse_csv(padrao) AS TABLE
  SELECT * FROM read_csv(padrao, delim=';', header=true, quote='"', encoding='CP1252', all_varchar=true, union_by_name=true);

CREATE OR REPLACE TABLE core.candidatura AS
SELECT
  SQ_CANDIDATO::BIGINT                  AS sq_candidato,
  ANO_ELEICAO::INT                      AS ano,
  NR_TURNO::INT                         AS turno,
  CD_ELEICAO::INT                       AS cd_eleicao,
  DS_ELEICAO                            AS ds_eleicao,
  core.data_br(DT_ELEICAO)              AS dt_eleicao,
  SG_UF                                 AS uf,
  SG_UE                                 AS sg_ue,
  NM_UE                                 AS nm_ue,
  CD_CARGO::INT                         AS cd_cargo,
  upper(DS_CARGO)                       AS cargo,
  NR_CANDIDATO::INT                     AS nr_candidato,
  NM_CANDIDATO                          AS nome,
  core.nome_norm(NM_CANDIDATO)          AS nome_norm,
  NM_URNA_CANDIDATO                     AS nome_urna,
  CASE WHEN regexp_matches(NR_CPF_CANDIDATO, '^[0-9]{11}$') THEN NR_CPF_CANDIDATO END AS cpf,
  core.nulo(NR_TITULO_ELEITORAL_CANDIDATO) AS titulo_eleitoral,
  NR_PARTIDO::INT                       AS nr_partido,
  SG_PARTIDO                            AS partido,
  NM_PARTIDO                            AS nm_partido,
  core.nulo(SG_FEDERACAO)               AS federacao,
  core.nulo(NM_COLIGACAO)               AS coligacao,
  DS_SITUACAO_CANDIDATURA               AS situacao_candidatura,
  core.nulo(DS_SIT_TOT_TURNO)           AS resultado,
  core.data_br(DT_NASCIMENTO)           AS dt_nascimento,
  core.nulo(SG_UF_NASCIMENTO)           AS uf_nascimento,
  DS_GENERO                             AS genero,
  DS_GRAU_INSTRUCAO                     AS grau_instrucao,
  DS_ESTADO_CIVIL                       AS estado_civil,
  DS_COR_RACA                           AS cor_raca,
  DS_OCUPACAO                           AS ocupacao,
  core.data_br(DT_GERACAO)              AS coletado_em
FROM tse_csv('$raw/consulta_cand_*/consulta_cand_*_BRASIL.csv');

CREATE OR REPLACE TABLE core.bem_declarado AS
SELECT
  SQ_CANDIDATO::BIGINT                  AS sq_candidato,
  ANO_ELEICAO::INT                      AS ano,
  NR_ORDEM_BEM_CANDIDATO::INT           AS nr_ordem,
  DS_TIPO_BEM_CANDIDATO                 AS tipo,
  DS_BEM_CANDIDATO                      AS descricao,
  core.valor_br(VR_BEM_CANDIDATO)       AS valor,
  core.data_br(DT_ULT_ATUAL_BEM_CANDIDATO) AS atualizado_em,
  core.data_br(DT_GERACAO)              AS coletado_em
FROM tse_csv('$raw/bem_candidato_*/bem_candidato_*_BRASIL.csv');

CREATE OR REPLACE TABLE core.cassacao AS
SELECT
  SQ_CANDIDATO::BIGINT                  AS sq_candidato,
  ANO_ELEICAO::INT                      AS ano,
  core.nulo(NR_PROCESSO)                AS nr_processo,
  DS_TP_MOTIVO                          AS tipo_motivo,
  DS_MOTIVO                             AS motivo,
  core.data_br(DT_GERACAO)              AS coletado_em
FROM tse_csv('$raw/motivo_cassacao_*/motivo_cassacao_*_BRASIL.csv');

CREATE OR REPLACE TABLE core.votos_munzona AS
SELECT
  SQ_CANDIDATO::BIGINT                  AS sq_candidato,
  ANO_ELEICAO::INT                      AS ano,
  NR_TURNO::INT                         AS turno,
  SG_UF                                 AS uf,
  CD_MUNICIPIO::INT                     AS cd_municipio_tse,
  NM_MUNICIPIO                          AS municipio,
  NR_ZONA::INT                          AS zona,
  QT_VOTOS_NOMINAIS::BIGINT             AS votos,
  QT_VOTOS_NOMINAIS_VALIDOS::BIGINT     AS votos_validos,
  core.data_br(DT_GERACAO)              AS coletado_em
FROM tse_csv('$raw/votacao_candidato_munzona_*/votacao_candidato_munzona_*_BRASIL.csv');

CREATE OR REPLACE TABLE core.receita_campanha AS
SELECT
  try_cast(SQ_CANDIDATO AS BIGINT)      AS sq_candidato,
  AA_ELEICAO::INT                       AS ano,
  SQ_RECEITA::BIGINT                    AS sq_receita,
  CASE WHEN regexp_matches(NR_CPF_CANDIDATO, '^[0-9]{11}$') THEN NR_CPF_CANDIDATO END AS cpf_candidato,
  core.nulo(NR_CNPJ_PRESTADOR_CONTA)    AS cnpj_campanha,
  core.data_br(DT_RECEITA)              AS data,
  core.valor_br(VR_RECEITA)             AS valor,
  DS_FONTE_RECEITA                      AS fonte_receita,
  DS_ORIGEM_RECEITA                     AS origem,
  DS_NATUREZA_RECEITA                   AS natureza,
  DS_ESPECIE_RECEITA                    AS especie,
  core.nulo(NR_CPF_CNPJ_DOADOR)         AS cpf_cnpj_doador,
  core.nulo(NM_DOADOR)                  AS nm_doador,
  core.nulo(NM_DOADOR_RFB)              AS nm_doador_rfb,
  try_cast(core.nulo(SQ_CANDIDATO_DOADOR) AS BIGINT) AS sq_candidato_doador,
  core.nulo(DS_RECEITA)                 AS descricao,
  core.data_br(DT_GERACAO)              AS coletado_em
FROM tse_csv('$raw/prestacao_de_contas_eleitorais_candidatos_*/receitas_candidatos_*_BRASIL.csv');

CREATE OR REPLACE TABLE core.despesa_campanha AS
SELECT
  try_cast(SQ_CANDIDATO AS BIGINT)      AS sq_candidato,
  AA_ELEICAO::INT                       AS ano,
  SQ_DESPESA::BIGINT                    AS sq_despesa,
  CASE WHEN regexp_matches(NR_CPF_CANDIDATO, '^[0-9]{11}$') THEN NR_CPF_CANDIDATO END AS cpf_candidato,
  core.nulo(NR_CNPJ_PRESTADOR_CONTA)    AS cnpj_campanha,
  core.data_br(DT_DESPESA)              AS data,
  core.valor_br(VR_DESPESA_CONTRATADA)  AS valor,
  DS_TIPO_FORNECEDOR                    AS tipo_fornecedor,
  core.nulo(NR_CPF_CNPJ_FORNECEDOR)     AS cpf_cnpj_fornecedor,
  core.nulo(NM_FORNECEDOR)              AS nm_fornecedor,
  core.nulo(NM_FORNECEDOR_RFB)          AS nm_fornecedor_rfb,
  DS_ORIGEM_DESPESA                     AS origem,
  core.nulo(DS_DESPESA)                 AS descricao,
  core.nulo(NR_DOCUMENTO)               AS nr_documento,
  core.data_br(DT_GERACAO)              AS coletado_em
-- Sem union_by_name: com ele o DuckDB 1.5 falha ("Attempted to access index 51 within vector of size 15") só nesta tabela.
FROM read_csv('$raw/prestacao_de_contas_eleitorais_candidatos_*/despesas_contratadas_candidatos_*_BRASIL.csv', delim=';', header=true, quote='"', encoding='CP1252', all_varchar=true);

-- O TSE mascara o CPF em consulta_cand desde 2022, mas a prestação de contas traz o CPF completo.
UPDATE core.candidatura c SET cpf = p.cpf
FROM (SELECT sq_candidato, any_value(cpf_candidato) AS cpf FROM
        (SELECT sq_candidato, cpf_candidato FROM core.receita_campanha UNION ALL
         SELECT sq_candidato, cpf_candidato FROM core.despesa_campanha)
      WHERE cpf_candidato IS NOT NULL GROUP BY 1) p
WHERE c.sq_candidato = p.sq_candidato AND c.cpf IS NULL;

-- Uma pessoa por CPF; nome e nascimento da candidatura mais recente.
CREATE OR REPLACE TABLE core.pessoa AS
SELECT cpf, nome, core.nome_norm(nome) AS nome_norm, core.cpf6(cpf) AS cpf6, dt_nascimento, uf_nascimento, genero, coletado_em
FROM core.candidatura
WHERE cpf IS NOT NULL
QUALIFY row_number() OVER (PARTITION BY cpf ORDER BY ano DESC, turno DESC) = 1;
