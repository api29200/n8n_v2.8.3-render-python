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

# Krok 3: Tworzymy venv w STAŁEJ lokalizacji domowej
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /home/node/python_venv && \
    chmod -R 777 /home/node/python_venv

# Krok 4: Folder tymczasowy w /tmp (omijamy noexec na Render)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: ROZWIĄZANIE PROBLEMU "Virtual environment is missing"
# Wersja 2.8.3 używa pnpm. Znajdujemy WSZYSTKIE foldery o nazwie task-runner-python 
# (nawet te ukryte w .pnpm) i linkujemy tam nasz venv.
RUN for dir in $(find /usr/local/lib/node_modules -type d -name "task-runner-python"); do \
      echo "Naprawiam folder: $dir"; \
      rm -rf "$dir/.venv" && ln -s /home/node/python_venv "$dir/.venv"; \
      chown -h node:node "$dir/.venv"; \
    done

# Krok 6: Zapewnienie uprawnień dla użytkownika node
RUN chown -R node:node /usr/local/lib/node_modules/n8n && \
    mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
