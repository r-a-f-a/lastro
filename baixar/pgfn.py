"""PGFN: dívida ativa da União, os três arquivos atuais."""
from baixar import RAW, baixar


def main():
    for nome in ("FGTS", "Nao_Previdenciario", "Previdenciario"):
        baixar(f"https://dadosabertos.pgfn.gov.br/Dados_abertos_{nome}.zip", RAW / "pgfn" / f"{nome}.zip")
