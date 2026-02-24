# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Kopiujemy pojedynczy, statyczny plik apk.
# Dzięki temu unikamy błędu 128 (nie nadpisujemy żadnych bibliotek współdzielonych środowiska Node.js).
COPY --from=builder /sbin/apk.static /sbin/apk

# Krok 2: Przywracamy system pakietów w zablokowanym n8n
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 3: Instalujemy Pythona i py3-virtualenv (którego n8n twardo szuka pod spodem w trybie internal)
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 4: Instalujemy wymagane biblioteki
RUN pip3 install requests --break-system-packages

USER node
