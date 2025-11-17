#!/bin/bash

# --- CONFIGURAÇÃO ---
# Certifique-se que este é o caminho correto para sua pasta de wallpapers
WALLPAPER_DIR="$HOME/Imagens/Wallpapers"

# Caminho para o seu script principal que atualiza o Pywal e tudo mais
UPDATE_SCRIPT="$HOME/.config/hypr/scripts/pywal-update.sh"


# --- LÓGICA DO SCRIPT ---
# 1. Encontra todos os arquivos de imagem (.jpg, .jpeg, .png) no diretório.
# 2. 'shuf -n 1' embaralha a lista e pega o primeiro item (um item aleatório).
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

# 3. Verifica se algum wallpaper foi realmente encontrado
if [ -z "$RANDOM_WALLPAPER" ]; then
    notify-send "Erro" "Nenhum wallpaper encontrado em $WALLPAPER_DIR"
    exit 1
fi

# 4. Executa o seu script de atualização principal, passando o wallpaper aleatório como argumento.
#    É isso que garante a sincronização perfeita!
echo "Trocando para wallpaper aleatório: $(basename "$RANDOM_WALLPAPER")"
"$UPDATE_SCRIPT" "$RANDOM_WALLPAPER"