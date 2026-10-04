from fastapi.testclient import TestClient

from env.server import app as env_app


def test_env_healthz_reports_unreachable_daemon(monkeypatch):
    monkeypatch.setattr(env_app, "DAEMON_URL", "http://127.0.0.1:1")
    resp = TestClient(env_app.app).get("/healthz")
    assert resp.status_code == 503
