-- TCU: listas de responsáveis em JSON. $raw = data/raw/tcu.
CREATE OR REPLACE TABLE core.sancao_tcu AS
SELECT
  regexp_extract(filename, 'responsaveis-([a-z-]+)\.json', 1) AS lista,
  nome,
  core.nome_norm(nome)                                        AS nome_norm,
  regexp_replace(numeroRegistro, '[^0-9]', '', 'g')           AS cpf_cnpj,
  coalesce(tipoRegistro, CASE WHEN length(regexp_replace(numeroRegistro, '[^0-9]', '', 'g')) = 11 THEN 'CPF' ELSE 'CNPJ' END) AS tipo_registro,
  nullif(municipio, '')                                       AS municipio,
  nullif(uf, '')                                              AS uf,
  numeroProcessoFormatado                                     AS nr_processo,
  numeroAcordaoFormatado                                      AS acordao,
  core.data_br(dataTransitoEmJulgado)                         AS transito_em_julgado,
  core.data_br(coalesce(dataFinalSancao, dataFinalFinsEleitorais)) AS fim,
  linkDeliberacoesProcesso                                    AS url,
  current_date                                                AS coletado_em
FROM read_json('$raw/responsaveis-*.json', filename=true, union_by_name=true, maximum_object_size=100000000);
