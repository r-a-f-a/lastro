"""Câmara dos Deputados: dumps anuais (2019 em diante), deputados e cota parlamentar (CEAP)."""
from datetime import date

from baixar import RAW, baixar

DUMPS = "https://dadosabertos.camara.leg.br/arquivos"
ANOS = range(2019, date.today().year + 1)
ANUAIS = ("proposicoes", "proposicoesAutores", "votacoes", "votacoesVotos", "eventos", "eventosPresencaDeputados")


def main():
    baixar(f"{DUMPS}/deputados/csv/deputados.csv", RAW / "camara" / "deputados.csv")
    for ano in ANOS:
        for colecao in ANUAIS:
            baixar(f"{DUMPS}/{colecao}/csv/{colecao}-{ano}.csv", RAW / "camara" / f"{colecao}-{ano}.csv")
        baixar(f"https://www.camara.leg.br/cotas/Ano-{ano}.csv.zip", RAW / "camara" / f"ceap-{ano}.zip")
