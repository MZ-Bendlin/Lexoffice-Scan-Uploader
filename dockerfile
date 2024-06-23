# Verwende ein Basisimage, das Bash unterstützt
FROM ubuntu:latest

# Installiere erforderliche Pakete (inotify-tools und curl)
RUN apt-get update && apt-get install -y \
    inotify-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setze das Arbeitsverzeichnis innerhalb des Containers
WORKDIR /app

# Erstelle ein Verzeichnis für das Skript und die zu überwachenden Dateien
RUN mkdir -p /upload

# Kopiere das Bash-Skript in den Container
COPY lex-upload.sh /app/lex-upload.sh

# Setze Ausführbarkeit für das Bash-Skript
RUN chmod +x /app/lex-upload.sh

# Starte das Bash-Skript beim Starten des Containers
CMD ["/bin/bash", "/app/lex-upload.sh"]