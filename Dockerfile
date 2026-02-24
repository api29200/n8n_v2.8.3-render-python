# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów apk (wymagane w obrazie n8n)
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i venv
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Instalacja venv bezpośrednio wewnątrz struktury n8n
# Szukamy folderu runnera (uwzględniając symlinki pnpm) i tworzymy w nim .venv
RUN RUNNER_DIR=$(find -L /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    echo "Instalacja venv w: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --no-cache-dir requests && \
    # Naprawa uprawnień - kluczowe dla błędu "insufficient permissions"
    chown -R node:node "$RUNNER_DIR" && \
    chmod -R 755 "$RUNNER_DIR/.venv"

# Krok 4: Uprawnienia do folderu roboczego na dysku Render
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
