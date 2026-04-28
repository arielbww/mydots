# Jantar dos Filósofos

Simulação clássica do problema de sincronização de processos (Dining Philosophers).

## Problema

5 filósofos sentam-se em volta de uma mesa circular. Cada filósofo alterna entre **pensar** e **comer**. Para comer, precisa de 2 talheres (esquerdo e direito). Há apenas 1 talher entre cada filósofo vizinho — recurso compartilhado.

## Solução Implementada

- **Recursos requeridos atomicamente**: filósofo só pega talheres se **ambos** estiverem livres
- **Impossível deadlock**: nunca pega apenas 1 talher
- **Sem starvation**: cada filósofo tem tempos finitos de THINK → HUNGRY → EATING

## Estados

| Estado | Português | Descrição |
|--------|-----------|-----------|
| PENSANDO | THINKING | Filósofo reflete |
| FAMINTO | HUNGRY | Aguardando talheres livres |
| COMENDO | EATING | Segurando ambos talheres |

## Estrutura de Dados

```
filosofos = [
    {id: int, estado: str, tempo: int, vezes_comeu: int},
    ...
]
talheres = ["Livre"|"F{id}", ...]  # 5 posições
```

- `tempo`: rodadas restantes no estado atual
- `vezes_comeu`: contador de refeições bem-sucedidas
- `talheres[i]`: "Livre" ou "F{id}" (filósofo que segura)

## Fluxo (por rodada)

1. **Alocação**: Filósofos FAMINTO tentam pegar talheres (ambos livres → COMENDO)
2. **Display**: Mostra estado atual da mesa e talheres
3. **Aguarda**: `time.sleep(1)`
4. **Atualização**: Decrementa tempo, libera talheres, transiciona estados

## Execução

```bash
python Jantar.py
```

Interromper com **Ctrl+C** para ver estatísticas finais (refeições por filósofo).

## Observações

- Tempo de COMER: 4 rodadas
- Tempo de PENSAR: 5 rodadas
- Tempos de início escalonados: `(i+1)*2` para evitar sincronismo perfeito
