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

# Krok 3: Tworzymy venv w stałej, bezpiecznej lokalizacji
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir --upgrade pip && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests

# Krok 4: Metoda Dywanowa - tworzymy symlinki we wszystkich znalezionych folderach runnera
# Dzięki temu n8n zawsze "zobaczy" folder .venv tam, gdzie go oczekuje,
# niezależnie od tego, jak pnpm ułożył strukturę katalogów.
RUN for dir in $(find /usr/local/lib/node_modules -type d -name "task-runner-python"); do \
      echo "Naprawiam runnera w: $dir"; \
      ln -s /home/node/python_venv "$dir/.venv"; \
      chown -h node:node "$dir/.venv"; \
    done

# Krok 5: Uprawnienia dla użytkownika node
RUN chown -R node:node /home/node/python_venv && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

USER node
