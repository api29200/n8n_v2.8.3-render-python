# Startujemy z oficjalnego obrazu n8n
FROM n8nio/n8n:2.9.0

# Przełączamy na root, żeby zainstalować Pythona
USER root

# Instalacja Pythona i pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv python3-distutils && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Powrót do użytkownika node
USER node

# Potwierdzenie wersji (opcjonalnie)
RUN python --version && pip --version
