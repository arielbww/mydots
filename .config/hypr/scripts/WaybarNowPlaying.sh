#!/bin/bash

# Pegando status do player
status=$(playerctl status 2>/dev/null)

# Debug (opcional, remove depois)
# echo "Status: $status" >> /tmp/np_debug.log

if [[ "$status" != "Playing" ]]; then
    exit 0  # Música pausada → módulo some
fi

# Pega artista e título
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

# Debug (opcional)
# echo "Artist: $artist, Title: $title" >> /tmp/np_debug.log

# Se não pegou nada, usa fallback
if [[ -z "$artist" ]]; then artist="Unknown Artist"; fi
if [[ -z "$title" ]]; then title="Unknown Title"; fi

# Monta display
maxlen=50
display="${artist} – ${title}"
if [[ ${#display} -gt $maxlen ]]; then
    display="${display:0:$maxlen}…"
fi

echo "$display"
