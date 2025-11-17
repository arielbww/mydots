#!/bin/bash
#
# Wallpaper Picker para Hyprland (Versão Final com swww + GIF)
# Autor: ariel
# Descrição: Seleciona wallpapers com preview via wofi e aplica transição suave via swww.
#

# === CONFIGURAÇÕES ===
WALLPAPERS="$HOME/Imagens/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-picker"
THUMB_WIDTH="280"
THUMB_HEIGHT="157"
WAL_BIN="$HOME/.local/bin/wal"
HOOKS="$HOME/.config/wal/hooks/hooks.sh"
FASTFETCH_CFG="$HOME/.config/fastfetch/config.jsonc"
SYNC_SCRIPT="$HOME/.config/hypr/scripts/pywal-update.sh"

# === CRIA CACHE SE NÃO EXISTIR ===
mkdir -p "$CACHE_DIR"

# === FUNÇÃO: Gera thumbnail otimizada ===
generate_thumbnail() {
    local input="$1"
    local output="$2"

    if command -v convert &>/dev/null; then
        # 🟩 Suporte a GIF — captura o primeiro frame
        convert "$input[0]" \
            -resize "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
            -gravity center \
            -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
            -filter Lanczos \
            -quality 95 \
            -unsharp 0.25x0.25+0.5+0.008 \
            -strip \
            +profile "*" \
            "$output"
    else
        cp "$input" "$output" 2>/dev/null
    fi
}

# === FUNÇÃO: Verifica novas imagens e atualiza cache ===
check_new_wallpapers() {
    find "$WALLPAPERS" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | while read -r img; do  # 🟩 GIF
        thumb_filename="$(basename "${img%.*}").png"
        thumb="$CACHE_DIR/$thumb_filename"

        if [[ ! -f "$thumb" ]] || [[ "$img" -nt "$thumb" ]]; then
            echo "🆕 Nova wallpaper detectada: $(basename "$img")" >&2
            generate_thumbnail "$img" "$thumb"
        fi
    done
}

# === FUNÇÃO: Gera menu com thumbnails ===
generate_menu() {
    check_new_wallpapers

    find "$WALLPAPERS" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort -V | while read -r img; do  # 🟩 GIF
        [[ -f "$img" ]] || continue
        thumb_filename="$(basename "${img%.*}").png"
        thumb="$CACHE_DIR/$thumb_filename"

        if [[ ! -f "$thumb" ]]; then
            echo "🔄 Gerando thumbnail para: $(basename "$img")" >&2
            generate_thumbnail "$img" "$thumb"
        fi

        [[ -f "$thumb" ]] && echo "img:$thumb"
    done
}

# === FUNÇÃO: Aplica wallpaper com swww ===
apply_wallpaper_swww() {
    local wallpaper="$1"

    # Inicia o daemon se não estiver ativo
    if ! pgrep -x "swww-daemon" >/dev/null; then
        echo "🚀 Iniciando swww-daemon..." >&2
        swww-daemon & disown
        sleep 0.5
    fi

    # Aplica transição suave
    swww img "$wallpaper" \
        --transition-type=outer \
        --transition-fps=120 \
        --transition-duration=1.5 \
        --transition-pos "$(hyprctl cursorpos)"

    echo "🎨 Wallpaper aplicado: $(basename "$wallpaper")" >&2
}

# === PROGRAMA PRINCIPAL ===
CHOICE=$(generate_menu | wofi --dmenu \
    --allow-images \
    --insensitive \
    --prompt "Select Wallpaper" \
    --conf "$HOME/.config/wofi/config.wallpaper"
)

[[ -z "$CHOICE" ]] && exit 0

SELECTED_THUMB="${CHOICE#img:}"
thumb_basename=$(basename "$SELECTED_THUMB" .png)
SELECTED=$(find "$WALLPAPERS" -type f -iname "${thumb_basename}.*" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | head -n 1)  # 🟩 GIF

if [[ ! -f "$SELECTED" ]]; then
    notify-send "❌ Erro" "Wallpaper não encontrado: $(basename "$SELECTED")"
    exit 1
fi

# === APLICA WALLPAPER ===
apply_wallpaper_swww "$SELECTED"

# === EXECUTA SYNC SCRIPT (se existir) ===
if [[ -x "$SYNC_SCRIPT" ]]; then
    "$SYNC_SCRIPT" "$SELECTED"
fi
