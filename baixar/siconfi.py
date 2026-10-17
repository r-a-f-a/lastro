"""SICONFI: entes e DCA Anexo I-C (receitas orçamentárias) por ente, 2019 em diante.
A API só devolve o DCA por id_ente, então são ~5.600 entes x anos, uma requisição cada."""
import json
from datetime import date

from baixar import RAW, baixar

ORDS = "https://apidatalake.tesouro.gov.br/ords/siconfi/tt"


def main():
    # Uma página só: a paginação por offset do ORDS não tem ordem estável e repete/omite entes.
    pagina = json.loads(baixar(f"{ORDS}/entes?limit=10000", RAW / "siconfi" / "entes.json").read_bytes())
    assert not pagina["hasMore"], "lista de entes maior que o limite"
    entes = pagina["items"]
    # ~39 mil requisições em série (com threads a API devolve 429): umas 11 h. Roda de madrugada; retoma de onde parou.
    for ano in range(2019, date.today().year):
        for e in entes:
            if e["esfera"] in ("M", "E"):
                baixar(f"{ORDS}/dca?an_exercicio={ano}&no_anexo=DCA-Anexo I-C&id_ente={e['cod_ibge']}&limit=5000",
                       RAW / "siconfi" / f"dca_{ano}" / f"{e['cod_ibge']}.json")
