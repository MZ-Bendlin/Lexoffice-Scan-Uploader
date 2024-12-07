# Verwende ein Basisimage mit Bash-Unterstützung
FROM ubuntu:latest

# Installiere erforderliche Pakete (inotify-tools, curl, tini)
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    inotify-tools \
    curl \
    tzdata \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Setze das Arbeitsverzeichnis innerhalb des Containers
WORKDIR /app

# Erstelle ein Verzeichnis für die zu überwachenden Dateien
RUN mkdir -p /upload

# Kopiere das Bash-Skript in den Container
COPY lex-upload.sh /app/lex-upload.sh

# Setze Ausführbarkeit für das Bash-Skript
RUN chmod +x /app/lex-upload.sh

# Verwende Tini als Init-Prozess (PID 1)
ENTRYPOINT ["/usr/bin/tini", "--", "/app/lex-upload.sh"]
