.PHONY: up down logs shell check test lint

DAEMON_DEV = docker compose --profile dev run --rm daemon-dev

up:
	docker compose up -d --build --wait

down:
	docker compose down

logs:
	docker compose logs -f

shell:
	docker compose exec sandbox bash

# Sandbox can build namespaces, and env can reach the daemon.
check:
	docker compose exec -T sandbox sh scripts/check_netns.sh
	curl -fsS http://localhost:8000/healthz && echo

test:
	$(DAEMON_DEV) go test ./...
	docker compose exec -T env pytest

lint:
	$(DAEMON_DEV) go vet ./...
	docker compose exec -T env ruff check .
