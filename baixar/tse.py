"""TSE: candidaturas, bens, cassações, votação, prestação de contas (2018–2024) e filiação partidária."""
from baixar import RAW, baixar

BASE = "https://cdn.tse.jus.br/estatistica/sead/odsele"
ANOS = (2018, 2020, 2022, 2024)
POR_ANO = {
    "consulta_cand": "consulta_cand_{ano}.zip",
    "bem_candidato": "bem_candidato_{ano}.zip",
    "motivo_cassacao": "motivo_cassacao_{ano}.zip",
    "votacao_candidato_munzona": "votacao_candidato_munzona_{ano}.zip",
    "prestacao_contas": "prestacao_de_contas_eleitorais_candidatos_{ano}.zip",
}


def main():
    for ano in ANOS:
        for pasta, nome in POR_ANO.items():
            nome = nome.format(ano=ano)
            baixar(f"{BASE}/{pasta}/{nome}", RAW / "tse" / nome)
    for brasil in (RAW / "tse").glob("*/*_BRASIL.csv"):
        # shortcut: o zip traz um CSV por UF e o consolidado _BRASIL com as mesmas linhas; só o consolidado fica
        for uf in brasil.parent.glob(brasil.name.replace("_BRASIL", "_[A-Z][A-Z]")):
            uf.unlink()
