# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Agresywne szukanie folderu runnera i tworzenie venv
# W n8n 2.8.3 folder task-runner-python jest głęboko w strukturze .pnpm
# find -L pozwoli nam przejść przez symlinki pnpm.
RUN export RUNNER_DIR=$(find -L /usr/local/lib/node_modules -type d -name "task-runner-python" | head -n 1) && \
    if [ -z "$RUNNER_DIR" ]; then echo "BŁĄD: Nie znaleziono folderu runnera!"; exit 1; fi && \
    echo "Znaleziono runnera w: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --no-cache-dir requests && \
    # Nadanie uprawnień 777, aby n8n (user node) mógł czytać/pisać wewnątrz sandboxa
    chown -R node:node "$RUNNER_DIR" && \
    chmod -R 777 "$RUNNER_DIR/.venv"

# Krok 4: Rozwiązanie błędu "insufficient permissions"
# Render blokuje egzekucję na dysku persistent. Używamy systemowego /tmp
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

USER node
WORKDIR /home/node
