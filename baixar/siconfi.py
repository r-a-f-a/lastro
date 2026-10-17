"""SICONFI: entes e DCA Anexo I-C (receitas orçamentárias) por ente, 2019 em diante.
A API só devolve o DCA por id_ente, então são ~5.600 entes x anos, uma requisição cada."""
import json
from concurrent.futures import ThreadPoolExecutor
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
    pedidos = [(ano, e["cod_ibge"]) for ano in range(2019, date.today().year) for e in entes if e["esfera"] in ("M", "E")]
    with ThreadPoolExecutor(4) as pool:  # ~39 mil requisições; em série levaria o dia inteiro
        list(pool.map(lambda p: baixar(f"{ORDS}/dca?an_exercicio={p[0]}&no_anexo=DCA-Anexo I-C&id_ente={p[1]}&limit=5000",
                                       RAW / "siconfi" / f"dca_{p[0]}" / f"{p[1]}.json"), pedidos))
