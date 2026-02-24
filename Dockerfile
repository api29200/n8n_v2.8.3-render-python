# ETAP 1: Pobieramy apk
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

# Krok 3: Tworzymy venv w obrazie (lokalizacja systemowa, nie na dysku sieciowym!)
# To eliminuje błąd "Insufficient permissions" związany z flagą noexec
RUN python3 -m venv /usr/local/n8n_python_venv && \
    /usr/local/n8n_python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /usr/local/n8n_python_venv && \
    chmod -R 755 /usr/local/n8n_python_venv

# Krok 4: Lokalizujemy ukryty folder runnera i linkujemy venv
# Używamy node -e, bo find zawodzi przy strukturze pnpm
RUN RUNNER_DIR=$(node -e "try { console.log(require('path').dirname(require.resolve('@n8n/task-runner-python/package.json'))) } catch(e) { console.log('') }") && \
    if [ -z "$RUNNER_DIR" ]; then \
        RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1); \
    fi && \
    if [ ! -z "$RUNNER_DIR" ]; then \
        echo "Linkowanie venv do: $RUNNER_DIR" && \
        ln -s /usr/local/n8n_python_venv "$RUNNER_DIR/.venv" && \
        chown -h node:node "$RUNNER_DIR/.venv"; \
    fi

# Krok 5: Przygotowanie folderu tymczasowego w /tmp (kluczowe wg forum n8n 63569)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

USER node
WORKDIR /home/node
