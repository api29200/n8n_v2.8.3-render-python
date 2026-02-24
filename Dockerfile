# ETAP 1: Pobieramy statyczny instalator apk
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w STAŁEJ lokalizacji systemowej (nie szukamy folderów n8n)
RUN python3 -m venv /usr/local/n8n_python_venv && \
    /usr/local/n8n_python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /usr/local/n8n_python_venv && \
    chmod -R 777 /usr/local/n8n_python_venv

# Krok 4: Rozwiązanie błędu "Insufficient Permissions"
# Tworzymy folder tymczasowy w systemowym /tmp (nie na dysku persistent)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: Przygotowanie folderu n8n
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
