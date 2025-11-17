#!/bin/bash

# Caminho do wallpaper passado pelo Waypaper (%s)
WALLPAPER_PATH="$1"

# --- ATUALIZAÇÃO DO TEMA ---
# Usa o Pywal para gerar a paleta de cores, sem definir o wallpaper (-n)
# e em modo silencioso (-q)
wal -i "$WALLPAPER_PATH" -n -q

# --- RECARREGAR SERVIÇOS ---
# Recarrega o SwayNC da maneira correta e confiável
swaync-client -rs

# --- ATUALIZAR APLICATIVOS ESPECÍFICOS ---
# Bloco para atualizar o CAVA
CONFIG_CAVA="$HOME/.config/cava/config"
COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ -f "$CONFIG_CAVA" ] && [ -f "$COLORS_JSON" ]; then
    for i in $(seq 1 8); do
        color=$(jq -r ".colors.color$i" "$COLORS_JSON")
        sed -i "s/^\(gradient_color_$i = \).*/\1'$color'/" "$CONFIG_CAVA"
    done
fi

# Wlogout não precisa de comando aqui. Ele lerá o tema ao ser aberto.

# Envia a notificação de sucesso para confirmar que o script rodou até o fim
notify-send "Tema Sincronizado" "Wallpaper e cores atualizadas com sucesso!"

exit 0
