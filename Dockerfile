# ETAP 1: Pobieramy obraz z narzędziem 'uv'
FROM ghcr.io/astral-sh/uv:latest AS uv-source

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Kopiujemy instalator uv
COPY --from=uv-source /uv /bin/uv

# Krok 2: Tworzymy środowisko. 
# Magia uv polega na tym, że jeśli nie znajdzie Pythona w systemie, 
# to automatycznie pobierze jego samodzielną wersję (standalone) z internetu.
# Dzięki temu w ogóle nie musimy dotykać zablokowanych pakietów systemowych Alpine.
RUN uv venv /opt/venv --python 3.11

# Krok 3: Sprawdzamy czy Python działa i instalujemy paczkę requests
RUN /opt/venv/bin/python --version && \
    uv pip install --python /opt/venv/bin/python requests

# Krok 4: Dodajemy środowisko do zmiennej PATH. 
# Dzięki temu Task Runner n8n automatycznie znajdzie komendę 'python3' w tym wyizolowanym folderze.
ENV PATH="/opt/venv/bin:$PATH"

# Krok 5: Oddajemy folder prawowitemu użytkownikowi, by uniknąć problemów z uprawnieniami
RUN chown -R node:node /opt/venv

USER node
