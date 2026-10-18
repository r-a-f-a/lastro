-- PGFN: dívida ativa, CSV latin1 com ';' sem aspas, decimal com ponto. $raw = data/raw/pgfn.
CREATE OR REPLACE TABLE core.divida_ativa AS
SELECT
  regexp_replace(CPF_CNPJ, '[^0-9X]', '', 'g')                AS cpf_cnpj,
  TIPO_PESSOA                                                 AS tipo_pessoa,
  NOME_DEVEDOR                                                AS nome,
  core.nome_norm(NOME_DEVEDOR)                                AS nome_norm,
  nullif(UF_DEVEDOR, '')                                      AS uf,
  NUMERO_INSCRICAO                                            AS nr_inscricao,
  SITUACAO_INSCRICAO                                          AS situacao,
  coalesce(RECEITA_PRINCIPAL, TIPO_CREDITO)                   AS natureza,
  core.data_br(DATA_INSCRICAO)                                AS inscrita_em,
  INDICADOR_AJUIZADO = 'SIM'                                  AS ajuizada,
  try_cast(VALOR_CONSOLIDADO AS DECIMAL(18, 2))               AS valor,
  regexp_extract(filename, '_(\d{6})\.csv', 1)                AS referencia,
  current_date                                                AS coletado_em
FROM read_csv('$raw/*/*.csv', delim=';', header=true, quote='', encoding='CP1252', all_varchar=true, union_by_name=true, filename=true);
