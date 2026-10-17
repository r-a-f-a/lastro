"""Portal da Transparência: sanções (CEIS, CNEP, CEPIM, CEAF) do dia, emendas parlamentares e compras mensais (2019 em diante)."""
from datetime import date, timedelta

import httpx

from baixar import RAW, UA, baixar

BASE = "https://portaldatransparencia.gov.br/download-de-dados"
SANCOES = ("ceis", "cnep", "cepim", "ceaf")


def ultimo_dia_publicado(dataset):
    """O snapshot do dia nem sempre já existe; volta até 7 dias."""
    for atras in range(8):
        dia = (date.today() - timedelta(days=atras)).strftime("%Y%m%d")
        r = httpx.head(f"{BASE}/{dataset}/{dia}", headers={"User-Agent": UA}, follow_redirects=True, timeout=60)
        if r.status_code == 200:
            return dia
    raise RuntimeError(f"{dataset}: nenhum snapshot nos últimos 7 dias")


def main():
    for ds in SANCOES:
        dia = ultimo_dia_publicado(ds)
        baixar(f"{BASE}/{ds}/{dia}", RAW / "portal" / f"{ds}_{dia}.zip")
    baixar(f"{BASE}/emendas-parlamentares/UNICO", RAW / "portal" / "emendas.zip")
    hoje = date.today()
    for ano in range(2019, hoje.year + 1):
        for mes in range(1, 13):
            if (ano, mes) >= (hoje.year, hoje.month):
                break
            try:
                baixar(f"{BASE}/compras/{ano}{mes:02d}", RAW / "portal" / f"compras_{ano}{mes:02d}.zip")
            except httpx.HTTPStatusError as e:
                if e.response.status_code not in (403, 404):
                    raise
                print(f"  compras/{ano}{mes:02d} ainda não publicado; parando aqui")
                return
