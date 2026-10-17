"""Senado Federal: senadores das legislaturas 56 e 57, votações nominais por ano e CEAPS (2019 em diante)."""
from datetime import date

from baixar import RAW, baixar

LEGIS = "https://legis.senado.leg.br/dadosabertos"
JSON = {"Accept": "application/json"}
ANOS = range(2019, date.today().year + 1)


def main():
    for leg in (56, 57):
        baixar(f"{LEGIS}/senador/lista/legislatura/{leg}", RAW / "senado" / f"senadores_leg{leg}.json", headers=JSON)
    for ano in ANOS:
        baixar(f"{LEGIS}/votacao?dataInicio={ano}-01-01&dataFim={ano}-12-31", RAW / "senado" / f"votacoes_{ano}.json", headers=JSON)
        baixar(f"https://adm.senado.gov.br/adm-dadosabertos/api/v1/senadores/despesas_ceaps/{ano}/csv", RAW / "senado" / f"ceaps_{ano}.csv")
