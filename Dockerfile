# ETAP 1: Pobieramy czystego Alpine'a (w tej samej wersji co pod spodem ma n8n)
FROM alpine:3.20 AS apk-source

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Kopiujemy narzędzie "apk" i jego pliki systemowe z czystego Alpine do n8n
COPY --from=apk-source /sbin/apk /sbin/apk
COPY --from=apk-source /lib/libapk.so* /lib/
COPY --from=apk-source /etc/apk /etc/apk
COPY --from=apk-source /usr/share/apk /usr/share/apk

# Krok 2: Odświeżamy przywrócone "apk" i instalujemy wymagane pakiety do Pythona
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv \
    python3-dev \
    build-base

# Krok 3: Tworzymy własny folder na paczki.
RUN mkdir -p /home/node/custom-python-packages

# Krok 4: Instalujemy paczki z użyciem flagi zapobiegającej błędom środowisk w nowym Pythonie
RUN pip3 install requests --break-system-packages -t /home/node/custom-python-packages

# Krok 5: Informujemy Node.js i Task Runnera, gdzie znajdują się paczki
ENV PYTHONPATH=/home/node/custom-python-packages

# Krok 6: Zmiana uprawnień dla użytkownika, na którym działa n8n (kluczowe!)
RUN chown -R node:node /home/node/custom-python-packages

USER node
