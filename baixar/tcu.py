"""TCU: listas de responsáveis (inabilitados, inidôneos, contas irregulares, fins eleitorais) pela API de certidões."""
from baixar import RAW, baixar

LISTAS = ("responsaveis-inabilitados", "responsaveis-inidoneos", "responsaveis-contas-irregulares", "responsaveis-fins-eleitorais")


def main():
    for lista in LISTAS:
        baixar(f"https://certidoes.apps.tcu.gov.br/api/publico/{lista}", RAW / "tcu" / f"{lista}.json", method="POST", json={})
