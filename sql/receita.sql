-- Receita Federal: CSVs cp1252 com ';', aspas e sem cabeçalho; nomes de arquivo internos são opacos (K3241...EMPRECSV).
-- $raw = data/raw/receita; a pasta do mês fica abaixo dele.
CREATE OR REPLACE MACRO rf_csv(padrao, nomes) AS TABLE
  SELECT * FROM read_csv(padrao, delim=';', header=false, quote='"', encoding='CP1252', all_varchar=true, names=nomes);

CREATE OR REPLACE TABLE core.rf_natureza AS SELECT codigo, descricao FROM rf_csv('$raw/*/Naturezas/*', ['codigo', 'descricao']);
CREATE OR REPLACE TABLE core.rf_qualificacao AS SELECT codigo, descricao FROM rf_csv('$raw/*/Qualificacoes/*', ['codigo', 'descricao']);
CREATE OR REPLACE TABLE core.rf_cnae AS SELECT codigo, descricao FROM rf_csv('$raw/*/Cnaes/*', ['codigo', 'descricao']);
CREATE OR REPLACE TABLE core.rf_municipio AS SELECT codigo, descricao FROM rf_csv('$raw/*/Municipios/*', ['codigo', 'descricao']);

CREATE OR REPLACE TABLE core.empresa AS
SELECT
  e.cnpj_basico,
  e.razao_social,
  core.nome_norm(e.razao_social)                              AS nome_norm,
  e.natureza_juridica                                         AS cod_natureza_juridica,
  n.descricao                                                 AS natureza_juridica,
  try_cast(replace(e.capital_social, ',', '.') AS DECIMAL(18, 2)) AS capital_social,
  CASE e.porte WHEN '01' THEN 'NÃO INFORMADO' WHEN '02' THEN 'ME' WHEN '03' THEN 'EPP' WHEN '05' THEN 'DEMAIS' END AS porte,
  regexp_extract(e.filename, '/(\d{4}-\d{2})/', 1)            AS referencia,
  current_date                                                AS coletado_em
FROM read_csv('$raw/*/Empresas?/*', delim=';', header=false, quote='"', encoding='CP1252', all_varchar=true, filename=true,
              names=['cnpj_basico', 'razao_social', 'natureza_juridica', 'qualificacao_responsavel', 'capital_social', 'porte', 'ente_federativo']) e
LEFT JOIN core.rf_natureza n ON n.codigo = e.natureza_juridica;

CREATE OR REPLACE TABLE core.estabelecimento AS
SELECT
  e.cnpj_basico || e.cnpj_ordem || e.cnpj_dv                   AS cnpj,
  e.cnpj_basico,
  e.matriz_filial = '1'                                       AS matriz,
  nullif(e.nome_fantasia, '')                                 AS nome_fantasia,
  CASE e.situacao WHEN '01' THEN 'NULA' WHEN '02' THEN 'ATIVA' WHEN '03' THEN 'SUSPENSA' WHEN '04' THEN 'INAPTA' WHEN '08' THEN 'BAIXADA' ELSE e.situacao END AS situacao,
  try_strptime(nullif(e.data_situacao, '0'), '%Y%m%d')::DATE  AS situacao_em,
  try_strptime(nullif(e.inicio_atividade, '0'), '%Y%m%d')::DATE AS inicio_atividade,
  e.cnae_principal                                            AS cod_cnae,
  c.descricao                                                 AS cnae,
  nullif(e.uf, '')                                            AS uf,
  e.municipio                                                 AS cod_municipio_rf,
  m.descricao                                                 AS municipio,
  current_date                                                AS coletado_em
FROM read_csv('$raw/*/Estabelecimentos?/*', delim=';', header=false, quote='"', encoding='CP1252', all_varchar=true,
              names=['cnpj_basico', 'cnpj_ordem', 'cnpj_dv', 'matriz_filial', 'nome_fantasia', 'situacao', 'data_situacao', 'motivo_situacao',
                     'cidade_exterior', 'pais', 'inicio_atividade', 'cnae_principal', 'cnae_secundaria', 'tipo_logradouro', 'logradouro', 'numero',
                     'complemento', 'bairro', 'cep', 'uf', 'municipio', 'ddd1', 'telefone1', 'ddd2', 'telefone2', 'ddd_fax', 'fax', 'email',
                     'situacao_especial', 'data_situacao_especial']) e
LEFT JOIN core.rf_cnae c ON c.codigo = e.cnae_principal
LEFT JOIN core.rf_municipio m ON m.codigo = e.municipio;

CREATE OR REPLACE TABLE core.socio AS
SELECT
  s.cnpj_basico,
  CASE s.tipo WHEN '1' THEN 'PJ' WHEN '2' THEN 'PF' WHEN '3' THEN 'ESTRANGEIRO' END AS tipo,
  s.nome,
  core.nome_norm(s.nome)                                      AS nome_norm,
  s.cpf_cnpj,                                                 -- CPF vem mascarado da Receita: ***123456**
  CASE WHEN s.tipo = '2' THEN core.cpf6(s.cpf_cnpj) END       AS cpf6,
  q.descricao                                                 AS qualificacao,
  try_strptime(nullif(s.entrada, '0'), '%Y%m%d')::DATE        AS entrada_em,
  s.faixa_etaria,
  current_date                                                AS coletado_em
FROM read_csv('$raw/*/Socios?/*', delim=';', header=false, quote='"', encoding='CP1252', all_varchar=true,
              names=['cnpj_basico', 'tipo', 'nome', 'cpf_cnpj', 'qualificacao', 'entrada', 'pais', 'representante', 'nome_representante',
                     'qualificacao_representante', 'faixa_etaria']) s
LEFT JOIN core.rf_qualificacao q ON q.codigo = s.qualificacao;
