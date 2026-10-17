-- IBGE: municípios e população do Censo 2022. $raw = data/raw/ibge.
CREATE OR REPLACE TABLE core.territorio AS
SELECT
  m."municipio-id"::INT                                       AS cod_municipio_ibge,
  m."municipio-nome"                                          AS municipio,
  m."UF-sigla"                                                AS uf,
  m."regiao-imediata-nome"                                    AS regiao_imediata,
  m."regiao-intermediaria-nome"                               AS regiao_intermediaria,
  p.populacao,
  current_date                                                AS coletado_em
FROM read_json('$raw/municipios.json') m
LEFT JOIN (SELECT s.localidade.id::INT AS cod, s.serie['2022']::BIGINT AS populacao
           FROM (SELECT unnest(resultados[1].series) AS s FROM read_json('$raw/populacao_2022.json'))) p ON p.cod = m."municipio-id";
