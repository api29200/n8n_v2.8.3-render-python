# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i venv
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy dedykowane środowisko venv w stałej lokalizacji
# To eliminuje problem z szukaniem ukrytych folderów pnpm
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir --upgrade pip && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /home/node/python_venv

# Krok 4: Uprawnienia do folderu roboczego n8n
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
