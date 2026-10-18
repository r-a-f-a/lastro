"""IBGE: municípios e população do Censo 2022."""
from baixar import RAW, baixar

API = "https://servicodados.ibge.gov.br/api"


def main():
    baixar(f"{API}/v1/localidades/municipios?view=nivelado", RAW / "ibge" / "municipios.json")
    baixar(f"{API}/v3/agregados/4714/periodos/2022/variaveis/93?localidades=N6[all]", RAW / "ibge" / "populacao_2022.json")
