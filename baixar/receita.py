"""Receita Federal: CNPJ (empresas, estabelecimentos, sócios e tabelas de domínio) do mês mais recente.
Os arquivos ficam num Nextcloud público; o WebDAV aceita o token do compartilhamento como usuário."""
import re

import httpx

from baixar import RAW, UA, baixar

TOKEN = "YggdBLfdninEJX9"  # https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9
WEBDAV = "https://arquivos.receitafederal.gov.br/public.php/webdav"
ARQUIVOS = [f"{n}{i}.zip" for n in ("Empresas", "Estabelecimentos", "Socios") for i in range(10)] + [
    "Simples.zip", "Cnaes.zip", "Qualificacoes.zip", "Naturezas.zip", "Municipios.zip", "Motivos.zip", "Paises.zip"]


def mes_mais_recente():
    r = httpx.request("PROPFIND", WEBDAV + "/", headers={"User-Agent": UA, "Depth": "1"}, auth=(TOKEN, ""), timeout=60)
    r.raise_for_status()
    return max(re.findall(r"/(\d{4}-\d{2})/", r.text))


def main():
    mes = mes_mais_recente()
    print(f"  mês {mes}")
    for nome in ARQUIVOS:
        baixar(f"{WEBDAV}/{mes}/{nome}", RAW / "receita" / mes / nome, auth=(TOKEN, ""))
