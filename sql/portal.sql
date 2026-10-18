-- Portal da Transparência: CSVs cp1252 com ';' e aspas. $raw = data/raw/portal.
CREATE OR REPLACE MACRO portal_csv(padrao) AS TABLE
  SELECT * FROM read_csv(padrao, delim=';', header=true, quote='"', encoding='CP1252', all_varchar=true, union_by_name=true);

CREATE OR REPLACE TABLE core.sancao AS
SELECT
  "CADASTRO"                                                  AS cadastro,
  "CÓDIGO DA SANÇÃO"                                          AS id_sancao,
  "TIPO DE PESSOA"                                            AS tipo_pessoa,
  regexp_replace("CPF OU CNPJ DO SANCIONADO", '[^0-9*]', '', 'g') AS cpf_cnpj,
  "NOME DO SANCIONADO"                                        AS nome,
  core.nome_norm("NOME DO SANCIONADO")                        AS nome_norm,
  "CATEGORIA DA SANÇÃO"                                       AS categoria,
  nullif("NÚMERO DO PROCESSO", '')                            AS nr_processo,
  core.data_br("DATA INÍCIO SANÇÃO")                          AS inicio,
  core.data_br("DATA FINAL SANÇÃO")                           AS fim,
  core.data_br("DATA DO TRÂNSITO EM JULGADO")                 AS transito_em_julgado,
  "ÓRGÃO SANCIONADOR"                                         AS orgao_sancionador,
  nullif("UF ÓRGÃO SANCIONADOR", '')                          AS uf_orgao,
  "FUNDAMENTAÇÃO LEGAL"                                       AS fundamentacao,
  core.data_br(regexp_extract(filename, '(\d{8})_', 1)[1:2] || '/' || regexp_extract(filename, '(\d{8})_', 1)[5:6] || '/' || regexp_extract(filename, '(\d{8})_', 1)[1:4]) AS _ignorar,
  try_strptime(regexp_extract(filename, '(\d{8})_', 1), '%Y%m%d')::DATE AS coletado_em
FROM (SELECT * FROM read_csv(['$raw/ceis_*/*_CEIS.csv', '$raw/cnep_*/*_CNEP.csv', '$raw/ceaf_*/*_Expulsoes.csv'],
                             delim=';', header=true, quote='"', encoding='CP1252', all_varchar=true, union_by_name=true, filename=true));
ALTER TABLE core.sancao DROP COLUMN _ignorar;

INSERT INTO core.sancao
SELECT 'CEPIM', "NÚMERO CONVÊNIO", 'J', "CNPJ ENTIDADE", "NOME ENTIDADE", core.nome_norm("NOME ENTIDADE"), 'Impedimento: ' || "MOTIVO DO IMPEDIMENTO",
       NULL, NULL, NULL, NULL, "ÓRGÃO CONCEDENTE", NULL, NULL, try_strptime(regexp_extract(filename, '(\d{8})_', 1), '%Y%m%d')::DATE
FROM read_csv('$raw/cepim_*/*_CEPIM.csv', delim=';', header=true, quote='"', encoding='CP1252', all_varchar=true, filename=true);

CREATE OR REPLACE TABLE core.emenda AS
SELECT
  "Código da Emenda"                                          AS id_emenda,
  "Ano da Emenda"::INT                                        AS ano,
  "Tipo de Emenda"                                            AS tipo,
  nullif("Código do Autor da Emenda", 'S/I')                  AS cod_autor,
  "Nome do Autor da Emenda"                                   AS autor,
  core.nome_norm("Nome do Autor da Emenda")                   AS autor_norm,
  try_cast("Código Município IBGE" AS INT)                    AS cod_municipio_ibge,
  nullif("Município", '')                                     AS municipio,
  nullif("UF", '')                                            AS uf,
  "Nome Função"                                               AS funcao,
  "Nome Ação"                                                 AS acao,
  core.valor_br("Valor Empenhado")                            AS valor_empenhado,
  core.valor_br("Valor Pago")                                 AS valor_pago,
  current_date                                                AS coletado_em
FROM portal_csv('$raw/emendas/EmendasParlamentares.csv')
WHERE "Ano da Emenda"::INT >= 2019;

CREATE OR REPLACE TABLE core.emenda_favorecido AS
SELECT
  "Código da Emenda"                                          AS id_emenda,
  "Ano/Mês"::INT                                              AS ano_mes,
  regexp_replace("Código do Favorecido", '[^0-9*]', '', 'g')  AS cpf_cnpj_favorecido,
  "Favorecido"                                                AS favorecido,
  "Tipo Favorecido"                                           AS tipo_favorecido,
  nullif("UF Favorecido", '')                                 AS uf,
  nullif("Município Favorecido", '')                          AS municipio,
  core.valor_br("Valor Recebido")                             AS valor,
  current_date                                                AS coletado_em
FROM portal_csv('$raw/emendas/EmendasParlamentares_PorFavorecido.csv')
WHERE "Ano/Mês"::INT >= 201901;

CREATE OR REPLACE TABLE core.contrato AS
SELECT
  'portal'                                                    AS fonte,
  "Número do Contrato"                                        AS nr_contrato,
  "Objeto"                                                    AS objeto,
  "Modalidade Compra"                                         AS modalidade,
  "Situação Contrato"                                         AS situacao,
  "Nome Órgão"                                                AS orgao,
  "Nome UG"                                                   AS unidade,
  core.data_br("Data Assinatura Contrato")                    AS assinado_em,
  core.data_br("Data Início Vigência")                        AS vigencia_inicio,
  core.data_br("Data Fim Vigência")                           AS vigencia_fim,
  regexp_replace("Código Contratado", '[^0-9*]', '', 'g')     AS cpf_cnpj_contratado,
  "Nome Contratado"                                           AS contratado,
  core.valor_br("Valor Inicial Compra")                       AS valor_inicial,
  core.valor_br("Valor Final Compra")                         AS valor_final,
  current_date                                                AS coletado_em
FROM portal_csv('$raw/compras_*/*_Compras.csv');
