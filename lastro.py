"""Lastro: baixar <fonte|tudo> | carregar <fonte|tudo> | cruzar | status"""
import importlib
import sys
from pathlib import Path

import duckdb

from baixar import RAW

FONTES = ["tse", "receita", "camara", "senado", "portal", "pncp", "pgfn", "tcu", "siconfi", "ibge"]
BASE = Path(__file__).resolve().parent
DB = BASE / "data" / "lastro.duckdb"


def conectar():
    DB.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB))
    executar_sql(con, "base")
    return con


def executar_sql(con, nome, fonte=""):
    sql = (BASE / "sql" / f"{nome}.sql").read_text().replace("$raw", str(RAW / fonte))
    con.execute(sql)


def baixar(fonte):
    for f in FONTES if fonte == "tudo" else [fonte]:
        print(f"== baixar {f}")
        importlib.import_module(f"baixar.{f}").main()


def carregar(fonte):
    con = conectar()
    for f in FONTES if fonte == "tudo" else [fonte]:
        print(f"== carregar {f}")
        executar_sql(con, f, f)


def cruzar():
    executar_sql(conectar(), "cruzar")


def status():
    con = conectar()
    for (tabela,) in con.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='core' ORDER BY 1").fetchall():
        (n,) = con.execute(f"SELECT count(*) FROM core.{tabela}").fetchone()
        print(f"core.{tabela:<22}{n:>14,}")
    for f in FONTES:
        arquivos = [p for p in (RAW / f).rglob("*") if p.is_file()] if (RAW / f).exists() else []
        if arquivos:
            from datetime import date
            ultimo = date.fromtimestamp(max(p.stat().st_mtime for p in arquivos))
            print(f"raw/{f:<10}{len(arquivos):>6} arquivos, último em {ultimo}")
        else:
            print(f"raw/{f:<10}  vazio")


if __name__ == "__main__":
    comando, *args = sys.argv[1:] or ["ajuda"]
    if comando in ("baixar", "carregar") and args:
        globals()[comando](args[0])
    elif comando in ("cruzar", "status"):
        globals()[comando]()
    else:
        sys.exit(__doc__)
