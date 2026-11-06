#!/bin/bash

# Arquivo permanente para cache de datas (evita consultas repetidas à rede)
ARQUIVO_CACHE=$HOME/.config/quarentena_changelog_cache.txt
mkdir -p $(dirname $ARQUIVO_CACHE)
touch $ARQUIVO_CACHE

# Cores para o terminal
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
SEM_COR='\033[0m'

# Valida modo de execução para o UNHOLD (liberação)
MODO_EXECUCAO=false
if [ "$1" == "--executar" ]; then
    MODO_EXECUCAO=true
fi

if ! command -v apt-listbugs &> /dev/null; then
    echo -e "${VERMELHO}❌ Erro: apt-listbugs não está instalado.${SEM_COR}"
    exit 1
fi

echo -e "${AZUL}Sincronizando índices dos repositórios...${SEM_COR}"
sudo apt-get update -qq

# 1. Captura pacotes da fila de upgrade e pacotes em hold
fila_upgrade=$(sudo apt-get -s upgrade | awk '/^Inst/ {print $2}')
pacotes_em_hold=$(apt-mark showhold)

# Combina as duas listas removendo duplicatas
todos_pacotes=$(echo -e "${fila_upgrade}\n${pacotes_em_hold}" | sort -u | sed '/^$/d')

if [ -z "$todos_pacotes" ]; then
    echo -e "${VERDE}✓ Nenhum pacote pendente e nenhum pacote em hold!${SEM_COR}"
    exit 0
fi

echo -e "\n${AZUL}======================================================================"
echo -e "🛡️ SISTEMA DE QUARENTENA AUTOMÁTICA ATIVO"
echo -e "• Bugs ou Quarentena < 5 dias ➔ HOLD AUTOMÁTICO"
if [ "$MODO_EXECUCAO" = true ]; then
    echo -e "• Quarentena concluída      ➔ UNHOLD AUTOMÁTICO"
else
    echo -e "• Quarentena concluída      ➔ MODO SIMULAÇÃO (Use --executar para liberar)"
fi
echo -e "======================================================================${SEM_COR}"

# Captura o timestamp do momento atual para o cálculo
data_atual_s=$(date +%s)

for pacote in $todos_pacotes; do
    echo "----------------------------------------------------------------------"

    estado_hold="Não"
    if echo "$pacotes_em_hold" | grep -q "^$pacote$" ; then
        estado_hold="Sim"
    fi

    versao_atual=$(dpkg-query -W -f='${Version}' "$pacote" 2>/dev/null)
    versao_nova=$(apt-cache policy "$pacote" | grep "Candidato:" | awk '{print $2}')

    if [ "$estado_hold" == "Sim" ]; then
        echo -e "${AMARELO}📦 Pacote: $pacote (Status: EM HOLD)${SEM_COR}"
    else
        echo -e "${AZUL}📦 Pacote: $pacote (Status: Na fila de Upgrade)${SEM_COR}"
    fi

    # Identifica se o pacote já alcançou a última versão disponível
    if [ "$versao_atual" == "$versao_nova" ] || [ -z "$versao_nova" ]; then
        echo "• Versão estável/instalada: $versao_atual (Última disponível)"
        versao_alvo=$versao_atual
    else
        echo "• Transição de versão: $versao_atual ➔ $versao_nova"
        versao_alvo=$versao_nova
    fi

    # --- Cálculo dinâmico baseado no seu código (com Cache de segurança) ---
    diferenca_dias=0
    chave_cache="${pacote}_${versao_alvo}"

    # Procura a data primeiro no cache local
    data_changelog=$(grep "^${chave_cache}" $ARQUIVO_CACHE | cut -d ' ' -f2-)

    if [ -z "$data_changelog" ]; then
        # Se não estiver no cache, faz a busca via changelog
        data_changelog=$(apt-get changelog "$pacote" 2>/dev/null | grep -E '^ --' | head -n 1 | sed 's/^.* //')

        # Salva no cache local
        if [ -n "$data_changelog" ]; then
            echo "${chave_cache} ${data_changelog}" >> $ARQUIVO_CACHE
        fi
    fi

    if [ -n "$data_changelog" ]; then
        timestamp_pacote=$(date -d "$data_changelog" +%s 2>/dev/null)
        if [ -n "$timestamp_pacote" ]; then
            diferenca_dias=$(( (data_atual_s - timestamp_pacote) / 86400 ))
            if [ $diferenca_dias -lt 0 ]; then
                diferenca_dias=0
            fi
        fi
    fi

    echo -e "• Idade da versão instalada/candidata: ${AMARELO}$diferenca_dias dias${SEM_COR}"

    # 2. Executa a listagem individual para o pacote
    saida_bugs=$(apt-listbugs list "$pacote" 2>/dev/null)

    # Aplica os filtros baseados em strings
    linhas_impeditivas=$(echo "$saida_bugs" | grep -E "Pendente|Encaminhado")
    linhas_resolvidas=$(echo "$saida_bugs" | grep -E "Resolvido")

    if [ -n "$linhas_impeditivas" ]; then
        echo -e "• Status de Bugs: ${VERMELHO}⚠️ BLOQUEADO! Encontrado status Pendente/Encaminhado.${SEM_COR}"
        if [ "$estado_hold" == "Sim" ]; then
            echo -e "• Ação: ${VERDE}Mantido em hold com sucesso (Sistema protegido).${SEM_COR}"
        else
            echo -e "• Ação: ${VERMELHO}⚠️ BUG CRÍTICO DETECTADO! Aplicando HOLD urgente...${SEM_COR}"
            sudo apt-mark hold "$pacote"
        fi

    elif [ -n "$linhas_resolvidas" ] || [ -z "$saida_bugs" ] || echo "$saida_bugs" | grep -q "Nenhum bug" ; then
        if [ -n "$linhas_resolvidas" ]; then
            echo -e "• Status de Bugs: ${VERDE}✅ Todos os bugs deste pacote constam como [Resolvido].${SEM_COR}"
        else
            echo -e "• Status de Bugs: ${VERDE}✅ Nenhum bug listado no apt-listbugs.${SEM_COR}"
        fi

        # Critério de liberação por tempo
        if [ "$diferenca_dias" -ge 5 ]; then
            if [ "$estado_hold" == "Sim" ]; then
                if [ "$MODO_EXECUCAO" = true ]; then
                    echo -e "• Ação: ${VERDE}Quarentena concluída e sem bugs ativos. Executando UNHOLD...${SEM_COR}"
                    sudo apt-mark unhold "$pacote"
                else
                    echo -e "• Ação Simulada: [SIMULAÇÃO] Quarentena concluída. Executaria: sudo apt-mark unhold $pacote"
                fi
            else
                echo -e "• Ação: Livre para atualizar normalmente."
            fi
        else
            dias_restantes=$(( 5 - diferenca_dias ))
            if [ "$estado_hold" == "Sim" ]; then
                echo -e "• Ação: ${AMARELO}Mantido em hold (Quarentena incompleta: faltam $dias_restantes dias).${SEM_COR}"
            else
                echo -e "• Ação: ${AMARELO}⏳ Quarentena incompleta ($diferenca_dias/5 dias). Aplicando HOLD temporal...${SEM_COR}"
                sudo apt-mark hold "$pacote"
            fi
        fi
    fi
done

echo "----------------------------------------------------------------------"
