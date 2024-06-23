#!/bin/bash

# Verzeichnis, das überwacht werden soll
watch_dir="/root/lex"

# Funktion, die aufgerufen wird, wenn eine neue PDF-Datei hinzugefügt wird
upload_file() {
    local filename="$1"
    echo "Neue PDF-Datei gefunden: $filename. Hochladen..."

    # Führe den cURL-Befehl aus, um die Datei hochzuladen
    response=$(curl -X POST "https://api.lexoffice.io/v1/files" \
        -H "Authorization: Bearer Dkf0J7agv.FAC7101SEdIPKVRplAd-Z5HKCciEQhC0MQ6UM1" \
        -H "Content-Type: multipart/form-data" \
        -H "Accept: application/json" \
        -F "file=@$watch_dir/$filename" -F "type=voucher")

    # Gib die Antwort des cURL-Befehls aus
    echo "Antwort des Servers: $response"
}

# Überwachung des Ordners auf Änderungen
inotifywait -m -e create -e moved_to --format '%f' "$watch_dir" | while read -r filename
do
    if [[ "$filename" == *.pdf ]]; then
        upload_file "$filename"
    fi
done
