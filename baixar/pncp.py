"""PNCP: contratos por API paginada, uma janela por mês desde 2021-01. Sem dump oficial; leva horas."""
import calendar
import json
import time
from datetime import date

from baixar import RAW, baixar

URL = "https://pncp.gov.br/api/consulta/v1/contratos"


def main():
    hoje = date.today()
    ano, mes = 2021, 1
    while (ano, mes) <= (hoje.year, hoje.month):
        ini = f"{ano}{mes:02d}01"
        fim = f"{ano}{mes:02d}{calendar.monthrange(ano, mes)[1]}"
        pagina = 1
        while True:
            arq = baixar(f"{URL}?dataInicial={ini}&dataFinal={fim}&tamanhoPagina=500&pagina={pagina}",
                         RAW / "pncp" / f"contratos_{ano}{mes:02d}_p{pagina:04d}.json")
            if arq.stat().st_size == 0 or json.loads(arq.read_bytes()).get("paginasRestantes", 0) == 0:
                break
            pagina += 1
            time.sleep(1.5)  # acima disso o PNCP devolve 429
        ano, mes = (ano + 1, 1) if mes == 12 else (ano, mes + 1)
