#!/bin/bash

# --- INÍCIO: Carregamento do Ambiente ---
# Esta seção é CRUCIAL. Ela importa as variáveis do sistema (como D-Bus)
# para que comandos como 'swaync-client' funcionem.
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
# --- FIM: Carregamento do Ambiente ---

# Log para depuração. Verifique este arquivo se algo der errado.
LOG_FILE="/tmp/waypaper-hook.log"
echo "--- $(date) ---" >> "$LOG_FILE"
echo "Script iniciado com wallpaper: $1" >> "$LOG_FILE"

# 1. Gera o tema com Pywal (sem definir o wallpaper novamente)
wal -i "$1" -n -q
echo "Pywal executado." >> "$LOG_FILE"

# 2. Recarrega o SwayNC
swaync-client -rs
echo "Comando para recarregar SwayNC enviado." >> "$LOG_FILE"

# 3. Atualiza o Cava
CONFIG_CAVA="$HOME/.config/cava/config"
COLORS_JSON="$HOME/.cache/wal/colors.json"
if [ -f "$CONFIG_CAVA" ]; then
    for i in $(seq 1 8); do
        color=$(jq -r ".colors.color$i" "$COLORS_JSON")
        sed -i "s/^\(gradient_color_$i = \).*/\1'$color'/" "$CONFIG_CAVA"
    done
    echo "Cava atualizado." >> "$LOG_FILE"
fi

# O Wlogout será atualizado na próxima vez que for aberto. Nenhuma ação necessária.

echo "Script concluído com sucesso." >> "$LOG_FILE"
notify-send "Waypaper Hook" "Tema sincronizado com sucesso!"

exit 0
