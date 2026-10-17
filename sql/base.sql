-- Executado em toda conexão: schema e macros compartilhadas pelos .sql de cada fonte.
CREATE SCHEMA IF NOT EXISTS core;
SET preserve_insertion_order = false;

-- Nome comparável: maiúsculo, sem acento, sem DA DE DO DAS DOS E, espaços únicos.
CREATE OR REPLACE MACRO core.nome_norm(x) AS
  trim(regexp_replace(regexp_replace(strip_accents(upper(x)), '\b(DA|DE|DO|DAS|DOS|E)\b', '', 'g'), ' +', ' ', 'g'));

-- Seis dígitos centrais do CPF (posições 4 a 9), a chave que sobrevive ao mascaramento: ***.123.456-** (Receita, CEAF) ou XXX123.456XX (PGFN).
CREATE OR REPLACE MACRO core.cpf6(x) AS (
  SELECT CASE WHEN length(m) = 11 THEN substr(m, 4, 6) WHEN length(regexp_replace(m, '[^0-9]', '', 'g')) = 6 THEN regexp_replace(m, '[^0-9]', '', 'g') END
  FROM (SELECT regexp_replace(upper(x), '[^0-9*X]', '', 'g') AS m));

-- Valores que o TSE usa como nulo.
CREATE OR REPLACE MACRO core.nulo(x) AS
  CASE WHEN x IN ('#NULO', '#NULO#', '#NE', '#NE#', '-1', '-3', '-4', 'NÃO DIVULGÁVEL', '') THEN NULL ELSE x END;

CREATE OR REPLACE MACRO core.data_br(x) AS try_strptime(core.nulo(x), '%d/%m/%Y')::DATE;
CREATE OR REPLACE MACRO core.valor_br(x) AS try_cast(replace(replace(core.nulo(x), '.', ''), ',', '.') AS DECIMAL(18, 2));
