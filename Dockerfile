# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
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

# Krok 3: Tworzymy venv wewnątrz DOKŁADNEJ ścieżki n8n 2.8.3
# Używamy ścieżki bezpośredniej, którą ten obraz posiada.
RUN mkdir -p /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python && \
    python3 -m venv /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python/.venv && \
    /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python/.venv/bin/pip install --no-cache-dir requests

# Krok 4: ROZWIĄZANIE PROBLEMU UPRAWNIEŃ (Insufficient Permissions)
# Nadajemy uprawnienia 777 do venv i folderów n8n, aby proces 'node' mógł tam swobodnie pisać i czytać.
RUN chmod -R 777 /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python/.venv && \
    chown -R node:node /usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python

# Krok 5: Przygotowanie folderu domowego i TMP (często TMP blokuje egzekucję)
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 777 /tmp

USER node
ENV PYTHONPATH=/usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python/.venv/lib/python3.12/site-packages
