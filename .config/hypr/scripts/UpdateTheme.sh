#!/bin/bash
# Versão Corrigida e Mais Robusta do Script de Atualização

echo "--- Iniciando atualização do tema ---"

# Pré-requisito: Garante que o 'jq' esteja instalado
if ! command -v jq &> /dev/null; then
    echo "ERRO: O comando 'jq' não foi encontrado. Por favor, instale com 'sudo pacman -S jq' e tente novamente."
    notify-send "Erro de Script" "O pacote 'jq' não está instalado."
    exit 1
fi

# 1. Pega o caminho do wallpaper que o Waypaper definiu
WAYPAPER_CONFIG="$HOME/.config/waypaper/config.ini"
if [ ! -f "$WAYPAPER_CONFIG" ]; then
    echo "ERRO: Arquivo de configuração do Waypaper não encontrado em $WAYPAPER_CONFIG"
    exit 1
fi
WALLPAPER_PATH=$(grep 'wallpaper =' "$WAYPAPER_CONFIG" | awk -F '= ' '{print $2}')
echo "Wallpaper encontrado: $WALLPAPER_PATH"

# 2. Executa o Pywal para gerar a nova paleta de cores
echo "Gerando paleta de cores com Pywal..."
wal -i "$WALLPAPER_PATH" -n -q

# 3. Recarrega o SwayNC (método correto)
echo "Recarregando SwayNC..."
swaync-client -rs


# 5. Wlogout - Nenhuma ação é necessária no script!
# Ele irá ler o CSS atualizado na próxima vez que você o executar manualmente.
# A linha "wlogout &" foi removida para que ele não abra toda vez.

echo "--- Atualização do tema concluída ---"
notify-send "Pywal" "Tema e wallpaper atualizados!"

exit 0