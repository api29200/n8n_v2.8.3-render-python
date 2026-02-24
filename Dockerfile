# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i narzędzia venv
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w bezpiecznej, systemowej lokalizacji kontenera
# Umieszczenie tego poza /home/node zapobiega konfliktom z uprawnieniami zamontowanego wolumenu.
RUN python3 -m venv /usr/local/n8n_venv && \
    /usr/local/n8n_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /usr/local/n8n_venv && \
    chmod -R 755 /usr/local/n8n_venv

# Krok 4: Rozwiązanie błędu "Insufficient Permissions"
# Tworzymy folder tymczasowy w /tmp kontenera (nie na dysku persistent!)
# To tu n8n zapisuje pliki .py i .json przed ich wykonaniem.
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: "Oszukujemy" mechanizm sprawdzający n8n 2.x
# Tworzymy fizyczny folder .venv tam, gdzie n8n go szuka, linkując go do naszego venv.
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    if [ ! -z "$RUNNER_DIR" ]; then \
        ln -s /usr/local/n8n_venv "$RUNNER_DIR/.venv" && \
        chown -h node:node "$RUNNER_DIR/.venv"; \
    fi

# Krok 6: Zapewnienie uprawnień do folderu domowego (tylko dla konfiguracji n8n)
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
