#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURAÇÕES E CONSTANTES ---
# Usar 'readonly' torna as variáveis imutáveis, evitando modificações acidentais.
readonly WALLPAPER_PATH="$1"
readonly CACHE_WAL="$HOME/.cache/wal/" # Apontando para o diretório do cache
readonly CONFIG_HYPRLOCK="$HOME/.config/hypr/hyprlock.conf"
readonly CONFIG_CAVA="$HOME/.config/cava/config" # <--- ADICIONADO: Caminho para config do Cava

# SUGESTÃO: Usar um array para os parâmetros é mais seguro.
readonly SWWW_PARAMS=(
    --transition-type any 
    --transition-fps 120 
    --transition-duration 1.3 
    --transition-pos center
)

# --- FUNÇÕES AUXILIARES ---

# Função para registrar mensagens no console.
log() {
    printf "🚀 %s\n" "$1"
}

# Função para exibir avisos.
warn() {
    printf "⚠️ Aviso: %s\n" "$1"
}

# Função para exibir erros e sair.
die() {
    printf "⛔ Erro: %s\n" "$1" >&2
    notify-send -u critical "Erro no Script de Wallpaper" "$1"
    exit 1
}

# Verifica todas as dependências de uma vez só.
check_dependencies() {
    log "Verificando dependências..."
    local missing_deps=()
    # Dependências críticas
    for cmd in jq wal swww notify-send; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        die "Dependências críticas não encontradas: ${missing_deps[*]}. Instale-as para continuar."
    fi
    # Avisa sobre dependências opcionais
    for cmd in bc sed pkill cava waybar swaync; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            warn "'$cmd' não encontrado. Algumas funcionalidades serão puladas."
        fi
    done
}

# Roda o pywal e verifica se o cache foi gerado com sucesso.
run_pywal() {
    log "Gerando tema com pywal..."
    wal -i "$WALLPAPER_PATH" --saturate 0.8 -q -n
    
    if [[ ! -f "${CACHE_WAL}colors.json" || ! -s "${CACHE_WAL}colors.json" ]]; then
        die "Falha ao gerar o cache de cores do pywal em '${CACHE_WAL}colors.json'."
    fi
}
# Atualiza tema do Bashtop
update_bashtop_theme() {
    local theme_dir="$HOME/.config/bashtop/user_themes"
    local wal_theme="$theme_dir/wal.theme"

    if [[ ! -d "$theme_dir" ]]; then
        mkdir -p "$theme_dir"
    fi

    # Gera o tema a partir do cache do pywal
    awk -F '=' '/^color/ {print "["$1"]\nforeground=" $2 "\nbackground=" $2}' "$CACHE_WAL/colors.sh" > "$wal_theme"

    log "Tema do Bashtop atualizado com Pywal: $wal_theme"
}

# Atualiza Hyprlock. Sua implementação já estava ótima.
update_hyprlock_config() {
    if [[ ! -f "$CONFIG_HYPRLOCK" ]]; then
        warn "Arquivo de configuração do Hyprlock não encontrado. Pulando."
        return
    fi

    log "Atualizando Hyprlock..."
    sed -i "s|^\s*path\s*=.*|    path = $WALLPAPER_PATH|g" "$CONFIG_HYPRLOCK"
}

# <--- INÍCIO DA FUNÇÃO ADICIONADA ---
# Atualiza as cores do Cava com base no Pywal
update_cava_config() {
    if [[ ! -f "$CONFIG_CAVA" ]]; then
        warn "Arquivo de configuração do Cava não encontrado em '$CONFIG_CAVA'. Pulando."
        return
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        warn "Comando 'jq' não encontrado. Pulando atualização do Cava."
        return
    fi

    log "Atualizando Cava..."

    # Ativa o modo gradiente no Cava
    sed -i "s/^\(;\s*\)*gradient\s*=.*/gradient = 1/g" "$CONFIG_CAVA"

    # Itera e aplica as 8 primeiras cores do Pywal (color1 a color8)
    for i in {1..8}; do
        # Lê a cor do cache .json do Pywal
        local color=$(jq -r ".colors.color$i" "${CACHE_WAL}colors.json")
        
        # Aplica a cor no config do Cava, garantindo que a linha seja descomentada
        # e o formato seja 'gradient_color_X = #XXXXXX'
        sed -i "s/^\(;\s*\)*gradient_color_$i\s*=.*/gradient_color_$i = '$color'/g" "$CONFIG_CAVA"
    done
}
# <--- FIM DA FUNÇÃO ADICIONADA ---

# Reinicia todos os serviços necessários em paralelo.
reload_services() {
    log "Recarregando serviços do desktop..."

    # Atualiza o Firefox em background
    (pywalfox update &>/dev/null & disown) &
    # Reinicia Waybar e SwayNC em background
    (pkill -x waybar || true) && (sleep 0.1 && waybar & disown) &
    (pkill -x swaync || true) && (sleep 0.2 && swaync >/dev/null 2>&1 & disown) &

    # Atualiza wlogout se o script existir
    if [[ -x "$HOME/.local/bin/wlogout-pywal-update.sh" ]]; then
        log "Atualizando wlogout..."
        "$HOME/.local/bin/wlogout-pywal-update.sh" &
    fi
    
    # Recarrega Hyprland
    hyprctl reload &>/dev/null || true

    # Reinicia Bashtop para pegar o tema do Pywal
    if pgrep -x bashtop > /dev/null; then
        log "Reiniciando Bashtop para aplicar o tema..."
        pkill -x bashtop
        bashtop & disown
    fi

    # <--- ADICIONADO: Recarrega o Cava ---
    # Envia sinal USR1 para o Cava recarregar a configuração sem reiniciar
    if pgrep -x cava > /dev/null; then
        log "Recarregando Cava..."
        pkill -USR2 cava
    fi
}

# --- SCRIPT PRINCIPAL ---
main() {
    # 1. Verificações iniciais
    if [[ $# -eq 0 ]]; then
        die "Uso: $0 /caminho/para/o/wallpaper.png"
    fi
    if [[ ! -f "$WALLPAPER_PATH" ]]; then
        die "Arquivo de wallpaper não encontrado: $WALLPAPER_PATH"
    fi

    check_dependencies

    # SUGESTÃO: Garante que o daemon do swww está rodando antes de usá-lo.
    if ! pgrep -x swww-daemon > /dev/null; then
        log "Iniciando swww-daemon..."
        swww init &>/dev/null
    fi

    # 2. Aplica o wallpaper (em background)
    log "🖼️ Aplicando wallpaper: $WALLPAPER_PATH"
    # SUGESTÃO: Expande o array de parâmetros de forma segura
    swww img "$WALLPAPER_PATH" "${SWWW_PARAMS[@]}" &

    # 3. Roda o pywal
    run_pywal

    # 4. Atualiza as configurações (em paralelo)
    update_hyprlock_config &
    update_bashtop_theme & # <--- MODIFICADO: Coloquei em background também
    update_cava_config &   # <--- ADICIONADO: Chamada para a nova função Cava

    wait # Espera as atualizações de config terminarem
    # 5. Recarrega os serviços
    reload_services

    # 6. Notificação final
    notify-send "Ambiente Atualizado" "Tema e serviços recarregados com base no novo wallpaper."
    log "Pronto ✅"
}

# Executa a função principal com todos os argumentos passados ao script.
main "$@"