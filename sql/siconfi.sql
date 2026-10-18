-- SICONFI: DCA Anexo I-C (receitas orçamentárias) por ente e exercício, um JSON por ente. $raw = data/raw/siconfi.
CREATE OR REPLACE TABLE core.financas_municipio AS
SELECT
  i.cod_ibge::INT                                             AS cod_municipio_ibge,
  i.exercicio::INT                                            AS exercicio,
  i.instituicao,
  i.uf,
  i.cod_conta,
  i.conta,
  i.coluna,
  try_cast(i.valor AS DECIMAL(18, 2))                         AS valor,
  i.populacao::BIGINT                                         AS populacao,
  current_date                                                AS coletado_em
FROM (SELECT unnest(items) AS i FROM read_json('$raw/dca_*/*.json', maximum_object_size=50000000, union_by_name=true));
