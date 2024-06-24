# Lexoffice-Scan-Uploader

Ein Docker-basierter Dienst zum automatischen Hochladen von Dateien zu Lexoffice. Dieser Dienst überwacht ein Verzeichnis auf neue Dateien und lädt sie automatisch zu Lexoffice hoch, wenn sie bestimmte Kriterien erfüllen.

## Voraussetzungen

- Docker
- Docker Compose

## Image selbst bauen.

1. Klone das Repository oder lade die Dateien `Dockerfile`, `lex-upload.sh` und `docker-compose.yml` herunte und lege die Dateien in ein Verzeichnis.

2. Erstelle das Docker-Image:

    ```sh
    docker build -t lexoffice-uploader:latest .
    ```

3. Erstelle eine Datei namens `docker-compose.yml` im selben Verzeichnis wie die `Dockerfile` und `lex-upload.sh`, und füge den folgenden Inhalt ein:

    ```yaml
    version: '3.8'

    services:
      lexoffice-uploader:
        image: lexoffice-scan-uploader:latest
        container_name: lexoffice-scan-uploader
        environment:
          - LEXOFFICE_API_KEY=your_actual_api_key
        volumes:
          - /path/to/local/upload:/upload
        restart: unless-stopped
    ```

4. Ersetze `your_actual_api_key` durch deinen tatsächlichen Lexoffice API-Schlüssel und `/path/to/local/upload` durch den Pfad zum lokalen Verzeichnis, das überwacht werden soll.

## Schnellstart

1. Führen den Befehl auf deinem Docker-Host aus.
```sh
docker pull mzbendlin/serverlexoffice-scan-uploader:latest
docker run -d --name lexoffice-uploader -e LEXOFFICE_API_KEY=your_actual_api_key -v /path/to/local/upload:/upload mz-bendlin/lexoffice-scan-uploader
```

2. Ersetze `your_actual_api_key` durch deinen tatsächlichen Lexoffice API-Schlüssel und `/path/to/local/upload` durch den Pfad zum lokalen Verzeichnis, das überwacht werden soll.
## Starten des Dienstes

Starte den Dienst mit Docker Compose:

```sh
docker-compose up -d
```
* * *
# Skript `lex-upload.sh`

Das Skript `lex-upload.sh` überwacht das Verzeichnis `/upload` auf neue Dateien. Es prüft die Dateigröße und Dateityp und lädt geeignete Dateien zu Lexoffice hoch. Dateien, die die Kriterien nicht erfüllen, werden in den Unterordner `/upload/errors` verschoben.

## Unterstützte Dateitypen

- PDF (.pdf)
- JPEG (.jpg, .jpeg)
- PNG (.png)

## Maximal erlaubte Dateigröße

5 MB

## Logs und Fehler

Alle Meldungen des Skripts werden mit einem Zeitstempel versehen. Dateien, die nicht hochgeladen werden können (aufgrund von Größe oder Serverfehlern), werden in den Ordner `/upload/errors` verschoben.

## Beispiel Verzeichnisstruktur

```.
├── Dockerfile
├── lex-upload.sh
├── docker-compose.yml
└── README.md
````

## Lizenz

Dieses Projekt ist lizenziert unter der MIT-Lizenz - siehe die `LICENSE` Datei für Details.

## Kontakt

Falls du Fragen oder Unterstützung benötigst, zögere nicht, dich zu melden.
