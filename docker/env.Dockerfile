# Unprivileged container for the environment server. It only talks to the
# daemon over HTTP and never touches a namespace.
FROM python:3.11-slim-bookworm

WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -e ".[dev]"

EXPOSE 8000
CMD ["uvicorn", "env.server.app:app", "--host", "0.0.0.0", "--port", "8000"]
