# Dockerfile
FROM n8nio/n8n:2.9.0

# Przełączamy na root, żeby zainstalować Pythona
USER root

# Instalacja Pythona i pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Powrót do użytkownika node
USER node
