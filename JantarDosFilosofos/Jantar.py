import time

# --- CONFIGURAÇÃO INICIAL ---
NUM_FILOSOFOS = 5
PENSANDO = "PENSANDO "
FAMINTO  = "FAMINTO "
COMENDO  = "COMENDO "

# Criamos os 5 filósofos
filosofos = []
for i in range(NUM_FILOSOFOS):
    filosofos.append({
        "id": i, 
        "estado": PENSANDO, 
        "tempo": (i + 1) * 2, # Tempos diferentes para iniciarem em momentos distintos
        "vezes_comeu": 0      # NOVO: Contador de quantas vezes comeu
    })

# Criamos os 5 talheres. 
# "Livre" significa que está na mesa. Se for pego, guardará o nome do Filósofo (ex: "F1")
talheres = ["Livre", "Livre", "Livre", "Livre", "Livre"]

print("=== Início do Jantar dos Filósofos com Talheres ===")
print("Pressione Ctrl+C a qualquer momento para ver o placar final.\n")

rodada = 1

# O bloco try/except vai capturar o comando de parada (Ctrl+C)
try:
    while True:
        print(f"\n--- Rodada {rodada} ---")
        
        # 1. TENTATIVA DE COMER (Alocação de Recursos)
        for f in filosofos:
            if f["estado"] == FAMINTO:
                # Identificando quais são os talheres deste filósofo
                talher_esq = f["id"]
                talher_dir = (f["id"] + 1) % NUM_FILOSOFOS
                
                # Ele só pega se OS DOIS estiverem livres! (Isso evita que o sistema trave)
                if talheres[talher_esq] == "Livre" and talheres[talher_dir] == "Livre":
                    # Pega os talheres (registra o ID do filósofo neles)
                    talheres[talher_esq] = f"F{f['id']}"
                    talheres[talher_dir] = f"F{f['id']}"
                    
                    f["estado"] = COMENDO
                    f["tempo"] = 4 # Ele vai passar 4 rodadas comendo
                    f["vezes_comeu"] += 1 # NOVO: Registra que ele conseguiu começar a comer

        # 2. MOSTRAR O STATUS DA MESA NA TELA
        for f in filosofos:
            if f["estado"] == COMENDO:
                esq = f["id"]
                dir = (f["id"] + 1) % NUM_FILOSOFOS
                print(f"Filósofo {f['id']} [{f['estado']}] -> Segurando talheres {esq} e {dir}")
            else:
                print(f"Filósofo {f['id']} [{f['estado']}]")
                
        # Mostra exatamente como está a lista de talheres agora
        print(f"Mesa (Talheres 0 a 4): {talheres}")

        # 3. PASSAGEM DO TEMPO
        time.sleep(1) # Aguarda 4 segundos (conforme você configurou)
        rodada += 1
        
        # 4. ATUALIZAR TEMPOS E LIBERAR TALHERES
        for f in filosofos:
            f["tempo"] -= 1
            
            if f["tempo"] <= 0:
                if f["estado"] == COMENDO:
                    # Terminou de comer, devolve os talheres para a mesa!
                    talher_esq = f["id"]
                    talher_dir = (f["id"] + 1) % NUM_FILOSOFOS
                    talheres[talher_esq] = "Livre"
                    talheres[talher_dir] = "Livre"
                    
                    f["estado"] = PENSANDO
                    f["tempo"] = 5 # Ficará 5 rodadas pensando
                    
                elif f["estado"] == PENSANDO:
                    f["estado"] = FAMINTO
                    # Fica faminto com tempo 0, apenas esperando a lógica da etapa 1 liberar os talheres

# 5. RESULTADO FINAL AO PRESSIONAR CTRL+C
except KeyboardInterrupt:
    print("\n\n" + "="*50)
    print("SIMULAÇÃO INTERROMPIDA PELO USUÁRIO (Ctrl+C)")
    print("="*50)
    print("Estatísticas finais (Refeições por Filósofo):")
    
    # Exibe o contador de cada um
    for f in filosofos:
        print(f"-> Filósofo {f['id']}: Comeu {f['vezes_comeu']} vezes")
        
    print("="*50)
    print("Fim do programa.")