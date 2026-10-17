"""SICONFI: entes e DCA Anexo I-C (receitas orçamentárias) por ente, 2019 em diante.
A API só devolve o DCA por id_ente, então são ~5.600 entes x anos, uma requisição cada."""
import json
from datetime import date

from baixar import RAW, baixar

ORDS = "https://apidatalake.tesouro.gov.br/ords/siconfi/tt"


def main():
    entes = []
    offset = 0
    while True:
        arq = baixar(f"{ORDS}/entes?limit=5000&offset={offset}", RAW / "siconfi" / f"entes_o{offset:05d}.json")
        pagina = json.loads(arq.read_bytes())
        entes += pagina["items"]
        if not pagina["hasMore"]:
            break
        offset += 5000
    # ~39 mil requisições em série (com threads a API devolve 429): umas 11 h. Roda de madrugada; retoma de onde parou.
    for ano in range(2019, date.today().year):
        for e in entes:
            if e["esfera"] in ("M", "E"):
                baixar(f"{ORDS}/dca?an_exercicio={ano}&no_anexo=DCA-Anexo I-C&id_ente={e['cod_ibge']}&limit=5000",
                       RAW / "siconfi" / f"dca_{ano}" / f"{e['cod_ibge']}.json")
