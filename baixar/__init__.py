"""Download para o data lake local. Arquivo existente com tamanho > 0 (ou zip já extraído) não é baixado de novo."""
import sys
import time
import zipfile
from pathlib import Path

import httpx

RAW = Path(__file__).resolve().parent.parent / "data" / "raw"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36 Lastro/0.1"


def baixar(url, destino, headers=None, method="GET", json=None, auth=None):
    destino = Path(destino)
    if destino.suffix == ".zip" and destino.with_suffix("").exists():
        return destino.with_suffix("")
    if destino.exists() and destino.stat().st_size > 0:
        return extrair(destino)
    destino.parent.mkdir(parents=True, exist_ok=True)
    parcial = destino.with_name(destino.name + ".part")
    for tentativa, espera in enumerate((2, 8, 30), 1):
        try:
            with httpx.stream(method, url, headers={"User-Agent": UA, **(headers or {})}, json=json, auth=auth,
                              follow_redirects=True, timeout=120) as r:
                r.raise_for_status()
                with open(parcial, "wb") as f:
                    for pedaco in r.iter_bytes(1 << 20):
                        f.write(pedaco)
            parcial.rename(destino)
            print(f"  {destino.relative_to(RAW)}  {destino.stat().st_size / 1e6:.1f} MB", flush=True)
            return extrair(destino)
        except (httpx.TransportError, httpx.HTTPStatusError) as e:
            if isinstance(e, httpx.HTTPStatusError) and e.response.status_code not in (405, 429) and e.response.status_code < 500:  # 405 do Portal é transitório
                raise
            if tentativa == 3:
                raise
            print(f"  tentativa {tentativa} falhou ({e}); aguardando {espera}s", file=sys.stderr)
            time.sleep(espera)


def extrair(arquivo):
    """Zip vira pasta de mesmo nome (sem .zip) e é apagado; DuckDB não lê dentro de zip e o disco é finito."""
    if arquivo.suffix != ".zip":
        return arquivo
    pasta = arquivo.with_suffix("")
    with zipfile.ZipFile(arquivo) as z:
        z.extractall(pasta)
    arquivo.unlink()
    return pasta
