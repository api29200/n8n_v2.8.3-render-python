FROM n8nio/n8n:2.8.3

USER root

# 1. Instalacja Pythona oraz brakujących bibliotek do wirtualnych środowisk
# Jest to absolutnie wymagane, by internal task runner mógł w ogóle wystartować w n8n v2+
RUN apk add --update --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv \
    python3-dev \
    build-base

# 2. Tworzymy własny folder na paczki. 
# Dzięki temu omijamy błędy środowiska globalnego w Alpine
RUN mkdir -p /home/node/custom-python-packages
RUN pip3 install requests -t /home/node/custom-python-packages

# 3. Informujemy Node.js i podproces Task Runnera, gdzie znajdują się paczki
ENV PYTHONPATH=/home/node/custom-python-packages

# 4. Zmiana uprawnień dla bezpiecznego użytkownika, na którym działa n8n
RUN chown -R node:node /home/node/custom-python-packages

USER node
