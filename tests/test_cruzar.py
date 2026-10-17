"""Regras de cruzamento em banco em memória com fixtures mínimas."""
from pathlib import Path

import duckdb
import pytest

SQL = Path(__file__).resolve().parent.parent / "sql"


@pytest.fixture
def con():
    con = duckdb.connect()
    con.execute((SQL / "base.sql").read_text())
    con.execute("""
      CREATE TABLE core.pessoa (cpf VARCHAR, nome VARCHAR, nome_norm VARCHAR, cpf6 VARCHAR, coletado_em DATE);
      CREATE TABLE core.candidatura (sq_candidato BIGINT, nome_norm VARCHAR, uf VARCHAR, partido VARCHAR, cargo VARCHAR, resultado VARCHAR);
      CREATE TABLE core.receita_campanha (sq_candidato BIGINT, cpf_cnpj_doador VARCHAR, data DATE, valor DECIMAL(18,2));
      CREATE TABLE core.contrato (nr_contrato VARCHAR, orgao VARCHAR, assinado_em DATE, cpf_cnpj_contratado VARCHAR, valor_inicial DECIMAL(18,2), valor_final DECIMAL(18,2), coletado_em DATE);
      CREATE TABLE core.estabelecimento (cnpj VARCHAR);
      CREATE TABLE core.socio (cnpj_basico VARCHAR, nome_norm VARCHAR, cpf_cnpj VARCHAR, cpf6 VARCHAR, qualificacao VARCHAR, entrada_em DATE, coletado_em DATE);
      CREATE TABLE core.sancao (cadastro VARCHAR, id_sancao VARCHAR, cpf_cnpj VARCHAR, nome_norm VARCHAR, categoria VARCHAR, orgao_sancionador VARCHAR, coletado_em DATE);
      CREATE TABLE core.sancao_tcu (lista VARCHAR, cpf_cnpj VARCHAR, tipo_registro VARCHAR, nr_processo VARCHAR, transito_em_julgado DATE, coletado_em DATE);
      CREATE TABLE core.divida_ativa (cpf_cnpj VARCHAR, tipo_pessoa VARCHAR, nome_norm VARCHAR, nr_inscricao VARCHAR, situacao VARCHAR, natureza VARCHAR, valor DECIMAL(18,2), coletado_em DATE);
      CREATE TABLE core.mandato (casa VARCHAR, id_parlamentar INT, nome VARCHAR, nome_norm VARCHAR, cpf VARCHAR, partido VARCHAR, uf VARCHAR, legislatura INT, coletado_em DATE);
      CREATE TABLE core.emenda (id_emenda VARCHAR, autor VARCHAR, autor_norm VARCHAR, valor_pago DECIMAL(18,2), coletado_em DATE);
      INSERT INTO core.pessoa VALUES ('12345678901', 'ANA DA SILVA', core.nome_norm('ANA DA SILVA'), core.cpf6('12345678901'), '2026-10-16');
    """)
    return con


def vinculos(con, regra):
    con.execute((SQL / "cruzar.sql").read_text())
    return con.execute("SELECT grau, destino_id FROM core.vinculo WHERE regra = ?", [regra]).fetchall()


def test_homonimo_com_cpf6_diferente_nao_liga(con):
    con.execute("INSERT INTO core.socio VALUES ('11111111', core.nome_norm('Ana da Silva'), '***999999**', core.cpf6('***999999**'), 'Sócio', NULL, current_date)")
    assert vinculos(con, "pessoa_socio") == []


def test_cpf6_e_nome_iguais_liga_com_grau_media(con):
    con.execute("INSERT INTO core.socio VALUES ('11111111', core.nome_norm('Ana da Silva'), '***456789**', core.cpf6('***456789**'), 'Sócio', NULL, current_date)")
    assert vinculos(con, "pessoa_socio") == [("media", "11111111")]


def test_cpf6_igual_mas_nome_diferente_nao_liga(con):
    con.execute("INSERT INTO core.socio VALUES ('11111111', core.nome_norm('Beatriz Souza'), '***456789**', core.cpf6('***456789**'), 'Sócio', NULL, current_date)")
    assert vinculos(con, "pessoa_socio") == []


def test_contrato_antes_da_doacao_nao_liga(con):
    con.execute("INSERT INTO core.receita_campanha VALUES (1, '11111111000191', '2022-08-01', 1000)")
    con.execute("INSERT INTO core.contrato VALUES ('C1', 'Órgão', '2022-07-01', '11111111000191', 10, 10, current_date)")
    assert vinculos(con, "doador_fornecedor") == []


def test_contrato_depois_da_doacao_liga_com_grau_alta(con):
    con.execute("INSERT INTO core.receita_campanha VALUES (1, '11111111000191', '2022-08-01', 1000)")
    con.execute("INSERT INTO core.contrato VALUES ('C1', 'Órgão', '2023-01-10', '11111111000191', 10, 10, current_date)")
    assert vinculos(con, "doador_fornecedor") == [("alta", "11111111000191")]


def test_cpf6_pgfn_e_receita():
    con = duckdb.connect()
    con.execute((SQL / "base.sql").read_text())
    assert con.execute("SELECT core.cpf6('XXX735.623XX'), core.cpf6('***.812.217-**'), core.cpf6('12345678901'), core.cpf6('')").fetchone() == ("735623", "812217", "456789", None)
