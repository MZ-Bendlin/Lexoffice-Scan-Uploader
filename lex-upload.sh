#!/bin/bash

# Verzeichnis, das überwacht werden soll
watch_dir="/upload"
error_dir="$watch_dir/errors"

# Maximal erlaubte Dateigröße (5MB)
max_size=5242880

# Funktion, um einen Zeitstempel zu erzeugen
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Überprüfen, ob die Umgebungsvariable gesetzt ist
if [ -z "$LEXOFFICE_API_KEY" ]; then
    echo "$(timestamp) - Die Umgebungsvariable LEXOFFICE_API_KEY ist nicht gesetzt."
    exit 1
fi

# Erstelle das Fehlerverzeichnis, falls es nicht existiert
if [ ! -d "$error_dir" ]; then
    echo "$(timestamp) - Erstelle Fehlerverzeichnis: $error_dir"
    mkdir -p "$error_dir"
fi

# Funktion, um eine Datei hochzuladen
upload_file() {
    local filename="$1"
    local filepath="$watch_dir/$filename"

    # Hier eine Pause von 5 Sekunden einfügen (kann je nach Bedarf angepasst werden)
    sleep 5
    
    # Dateigröße überprüfen
    file_size=$(stat -c%s "$filepath")
    
    if (( file_size > max_size )); then
        echo "$(timestamp) - Die Datei $filename überschreitet die maximale Größe von 5MB und wird nicht hochgeladen."
        mv "$filepath" "$error_dir/"
        return
    fi

    echo "$(timestamp) - Neue Datei gefunden: $filename. Hochladen zu Lexoffice..."

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
        echo "$(timestamp) - Die Datei $filename wurde erfolgreich hochgeladen."
        rm "$filepath"  # Datei aus dem Überwachungsverzeichnis löschen
    else
        echo "$(timestamp) - Fehler beim Hochladen der Datei $filename."
        echo "$(timestamp) - HTTP-Status: $http_status"
        echo "$(timestamp) - Antwort des Servers: $response_body"
        mv "$filepath" "$error_dir/"
    fi
}

# Überwachung des Ordners auf neue Dateien
inotifywait -m -e create -e moved_to --format '%f' "$watch_dir" | while read -r filename
do
    # Konvertiere den Dateinamen in Kleinbuchstaben
    lower_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ "$lower_filename" == *.pdf || "$lower_filename" == *.jpg || "$lower_filename" == *.jpeg || "$lower_filename" == *.png ]]; then
        upload_file "$filename"
    fi
done