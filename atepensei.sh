#!/bin/bash

SITES_FILE="sites.txt"
OUTPUT_DIR="resultnucleibos"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1451249120760037440/3_VDYQP3rT4NTp5HKwdpAndSvdRZtmvuN1r0ANVNcyal7vA_OEgCh8IaIAt8sAWn-cKO"

mkdir -p "$OUTPUT_DIR"

while IFS= read -r SITE || [[ -n "$SITE" ]]; do
    SITE=$(echo "$SITE" | tr -d '\r\n ')
    [[ -z "$SITE" ]] && continue

    SAFE_NAME=$(echo "$SITE" | sed 's#https\?://##g; s#[/:]#_#g')
    OUTPUT_FILE="$OUTPUT_DIR/$SAFE_NAME.txt"

    echo "[*] Escaneando: $SITE"

    nuclei \
        -u "$SITE" \
        -severity critical,high \
        -silent \
        -o "$OUTPUT_FILE"

    if [[ -s "$OUTPUT_FILE" ]]; then
        echo "[+] Enviando resultado para o Discord: $SAFE_NAME.txt"

        curl -s -X POST "$DISCORD_WEBHOOK" \
            -F "payload_json={
                \"username\": \"Nuclei Scanner\",
                \"content\": \"🚨 **VULNERABILIDADES CRÍTICAS/ALTAS ENCONTRADAS**\\n🌐 Site: $SITE\"
            }" \
            -F "file=@$OUTPUT_FILE"
    else
        echo "[-] Nenhum achado crítico/alto para $SITE"
        rm -f "$OUTPUT_FILE"
    fi

    echo "----------------------------------------"
done < "$SITES_FILE"

echo "[✓] Todos os scans finalizados"
