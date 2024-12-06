# Verwende ein Basisimage, mit Bash unterstützung
FROM ubuntu:latest

# Installiere erforderliche Pakete (inotify-tools und curl)
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    inotify-tools \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Setze das Arbeitsverzeichnis innerhalb des Containers
WORKDIR /app

# Erstelle ein Verzeichnis für die zu überwachenden Dateien
RUN mkdir -p /upload

# Kopiere das Bash-Skript in den Container
COPY lex-upload.sh /app/lex-upload.sh

# Setze Ausführbarkeit für das Bash-Skript
RUN chmod +x /app/lex-upload.sh

# Starte das Bash-Skript beim Starten des Containers und sorge für sauberes Beenden
CMD ["/bin/bash", "-c", "/app/lex-upload.sh; exit 0"]
