# Startujemy od oficjalnego obrazu n8n
FROM n8nio/n8n:2.9.0

# Przełączamy na root, żeby zainstalować Node.js 22 i Pythona
USER root

# Aktualizacja systemu i zależności
RUN apt-get update && apt-get install -y \
    curl python3 python3-pip python3-venv python3-distutils gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Instalacja Node.js 22.x ręcznie
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v

# Powrót do użytkownika n8n
USER node
WORKDIR /home/node

# Port i entrypoint
EXPOSE 5678
ENTRYPOINT ["n8n"]
CMD ["start"]
