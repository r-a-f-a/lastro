-- PNCP: contratos, uma página JSON por arquivo. $raw = data/raw/pncp. Entra na mesma core.contrato do Portal.
DELETE FROM core.contrato WHERE fonte = 'pncp';
INSERT INTO core.contrato
SELECT
  'pncp',
  c.numeroControlePNCP,
  c.objetoContrato,
  c.tipoContrato.nome,
  NULL,
  c.orgaoEntidade.razaoSocial,
  c.unidadeOrgao.nomeUnidade,
  try_cast(c.dataAssinatura AS DATE),
  try_cast(c.dataVigenciaInicio AS DATE),
  try_cast(c.dataVigenciaFim AS DATE),
  regexp_replace(c.niFornecedor, '[^0-9*]', '', 'g'),
  c.nomeRazaoSocialFornecedor,
  try_cast(c.valorInicial AS DECIMAL(18, 2)),
  try_cast(c.valorGlobal AS DECIMAL(18, 2)),
  current_date
FROM (SELECT unnest(data) AS c FROM read_json('$raw/contratos_*.json', maximum_object_size=200000000, union_by_name=true));
