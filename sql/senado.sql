-- Senado: JSON das APIs e CSV UTF-8 do CEAPS. $raw = data/raw/senado.
-- Entra nas tabelas criadas por camara.sql; apaga o que é do Senado antes para poder rodar de novo.
DELETE FROM core.mandato WHERE casa = 'senado';
DELETE FROM core.despesa_cota WHERE casa = 'senado';
DELETE FROM core.votacao WHERE casa = 'senado';
DELETE FROM core.voto WHERE casa = 'senado';
INSERT INTO core.mandato
SELECT
  'senado', p.IdentificacaoParlamentar.CodigoParlamentar::INT, p.IdentificacaoParlamentar.NomeParlamentar,
  p.IdentificacaoParlamentar.NomeCompletoParlamentar, core.nome_norm(p.IdentificacaoParlamentar.NomeCompletoParlamentar),
  NULL, p.IdentificacaoParlamentar.SiglaPartidoParlamentar, p.IdentificacaoParlamentar.UfParlamentar,
  regexp_extract(filename, 'leg(\d+)', 1)::INT, NULL, NULL, current_date
FROM (SELECT unnest(ListaParlamentarLegislatura.Parlamentares.Parlamentar) AS p, filename
      FROM read_json('$raw/senadores_leg*.json', filename=true, maximum_object_size=50000000));

INSERT INTO core.despesa_cota
SELECT
  'senado', COD_SENADOR::INT, NOME_SENADOR, NULL, NULL, ANO::INT, "MÊS"::INT, TIPO_DESPESA, NOME_FORNECEDOR,
  regexp_replace(CPF_CNPJ_FORNECEDOR, '[^0-9]', '', 'g'), core.data_br(DATA), NULL, NULL,
  try_cast(replace(VALOR_REEMBOLSADO, ',', '.') AS DECIMAL(18, 2)), NULL, current_date
FROM read_csv('$raw/ceaps_*.csv', delim=';', header=true, quote='"', all_varchar=true, union_by_name=true);

INSERT INTO core.votacao
SELECT
  'senado', codigoSessaoVotacao::VARCHAR, try_cast(dataSessao AS DATE), 'PLEN', descricaoVotacao, resultadoVotacao = 'A',
  totalVotosSim, totalVotosNao, totalVotosAbstencao, codigoMateria, identificacao, current_date
FROM read_json('$raw/votacoes_*.json', maximum_object_size=100000000);

INSERT INTO core.voto
SELECT
  'senado', codigoSessaoVotacao::VARCHAR, v.codigoParlamentar, v.nomeParlamentar, v.siglaPartidoParlamentar, v.siglaUFParlamentar,
  v.siglaVotoParlamentar, try_cast(dataSessao AS TIMESTAMP), current_date
FROM (SELECT codigoSessaoVotacao, dataSessao, unnest(votos) AS v FROM read_json('$raw/votacoes_*.json', maximum_object_size=100000000));
