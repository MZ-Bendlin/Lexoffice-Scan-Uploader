#!/bin/bash

# Verzeichnis, das überwacht werden soll
watch_dir="/upload"

# Maximal erlaubte Dateigröße (5MB)
max_size=5242880

# Überprüfen, ob die Umgebungsvariable gesetzt ist
if [ -z "$LEXOFFICE_API_KEY" ]; then
    echo "Die Umgebungsvariable LEXOFFICE_API_KEY ist nicht gesetzt."
    exit 1
fi

# Funktion, um eine Datei hochzuladen
upload_file() {
    local filename="$1"
    local filepath="$watch_dir/$filename"
    
    # Dateigröße überprüfen
    file_size=$(stat -c%s "$filepath")
    
    if (( file_size > max_size )); then
        echo "Die Datei $filename überschreitet die maximale Größe von 5MB und wird nicht hochgeladen."
        return
    fi

    echo "Neue Datei gefunden: $filename. Hochladen zu Lexoffice..."

    # Hier eine Pause von 5 Sekunden einfügen (kann je nach Bedarf angepasst werden)
    sleep 5

    # Datei hochladen mit cURL
    response=$(curl -w "\n%{http_code}" -s \
        -X POST "https://api.lexoffice.io/v1/files" \
        -H "Authorization: Bearer $LEXOFFICE_API_KEY" \
        -H "Content-Type: multipart/form-data" \
        -H "Accept: application/json" \
        -F "file=@$filepath" \
        -F "type=voucher")

    http_status=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    # Überprüfen, ob der Upload erfolgreich war
    if [[ "$http_status" -eq 202 ]]; then
        echo "Die Datei $filename wurde erfolgreich hochgeladen."
        rm "$filepath"  # Datei aus dem Überwachungsverzeichnis löschen
    else
        echo "Fehler beim Hochladen der Datei $filename."
        echo "HTTP-Status: $http_status"
        echo "Antwort des Servers: $response_body"
    fi
}

# Überwachung des Ordners auf neue Dateien
inotifywait -m -e create -e moved_to --format '%f' "$watch_dir" | while read -r filename
do
    if [[ "$filename" == *.pdf || "$filename" == *.jpg || "$filename" == *.jpeg || "$filename" == *.png ]]; then
        upload_file "$filename"
    fi
done