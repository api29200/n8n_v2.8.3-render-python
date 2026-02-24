# Używamy oficjalnego obrazu n8n z Node.js >= 22
FROM n8nio/n8n:2.9.0-node22

# Przełączamy na root, aby zainstalować Pythona
USER root

# Instalacja Pythona i pip w Debianie
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-distutils \
    && ln -sf python3 /usr/bin/python \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Wracamy do użytkownika n8n (wbudowany w obraz n8n)
USER node
WORKDIR /home/node

# Port i entrypoint
EXPOSE 5678
ENTRYPOINT ["n8n"]
CMD ["start"]
