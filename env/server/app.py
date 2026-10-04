"""Environment server.

Placeholder until the OpenEnv environment lands: it only reports whether it
can reach the daemon.
"""

import os

import httpx
from fastapi import FastAPI, HTTPException

DAEMON_URL = os.environ.get("DAEMON_URL", "http://localhost:8700")

app = FastAPI(title="netops gym environment")


@app.get("/healthz")
def healthz() -> dict:
    try:
        resp = httpx.get(f"{DAEMON_URL}/healthz", timeout=3)
        resp.raise_for_status()
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=503, detail=f"daemon unreachable: {exc}") from exc
    return {"status": "ok", "daemon": resp.json()}
