#!/bin/bash

# Cores para o terminal
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
SEM_COR='\033[0m'

# Valida modo de execução
MODO_EXECUÇÃO=false
if [ "$1" == "--executar" ]; then
    MODO_EXECUÇÃO=true
fi

if ! command -v apt-listbugs &> /dev/null; then
    echo -e "${VERMELHO}❌ Erro: 'apt-listbugs' não está instalado.${SEM_COR}"
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

# Calcula a idade do repositório local para a quarentena de 5 dias
arquivo_sid_lista=$(ls /var/lib/apt/lists/*_debian_dists_sid_*_Packages 2>/dev/null | head -n 1)
if [ -n "$arquivo_sid_lista" ]; then
    timestamp_pendente=$(stat -c %Y "$arquivo_sid_lista")
    data_atual_s=$(date +%s)
    diferenca_dias=$(( (data_atual_s - timestamp_pendente) / 86400 ))
else
    diferenca_dias=0
fi

echo -e "\n${AZUL}======================================================================"
if [ "$MODO_EXECUÇÃO" = true ]; then
    echo -e "   🚀 EXECUTANDO AUTOMATAÇÃO: APLICANDO AS REGRAS NO SISTEMA          "
else
    echo -e "   🔍 MODO SIMULAÇÃO (DRY-RUN): NENHUMA ALTERAÇÃO REAL SERÁ FEITA     "
fi
echo -e "======================================================================${SEM_COR}"
echo -e "ℹ️  Idade estimada dos pacotes nos repositórios: ${AMARELO}$diferenca_dias dias${SEM_COR}"
echo "----------------------------------------------------------------------"

for pacote in $todos_pacotes; do
    estado_hold="Não"
    if echo "$pacotes_em_hold" | grep -q "^$pacote$"; then
        estado_hold="Sim"
    fi

    versao_atual=$(dpkg-query -W -f='${Version}' "$pacote" 2>/dev/null)
    versao_nova=$(apt-cache policy "$pacote" | grep "Candidato:" | awk '{print $2}')

    if [ "$estado_hold" == "Sim" ]; then
        echo -e "${AMARELO}📦 Pacote: $pacote (Status: EM HOLD)${SEM_COR}"
    else
        echo -e "${AZUL}📦 Pacote: $pacote (Status: Na fila de Upgrade)${SEM_COR}"
    fi

    if [ "$versao_atual" == "$versao_nova" ] || [ -z "$versao_nova" ]; then
        echo "   • Versão estável/instalada: $versao_atual (Última disponível)"
        ja_atualizado=true
    else
        echo "   • Transição de versão: $versao_atual ➔ $versao_nova"
        ja_atualizado=false
    fi

    # 2. Executa a listagem individual para o pacote
    saida_bugs=$(apt-listbugs list "$pacote" 2>/dev/null)

    # Aplica os filtros baseados em strings
    linhas_impeditivas=$(echo "$saida_bugs" | grep -E "Pendente|Encaminhado")
    linhas_resolvidas=$(echo "$saida_bugs" | grep -E "Resolvido")

    if [ -n "$linhas_impeditivas" ]; then
        echo -e "   • Status de Bugs:    ${VERMELHO}⚠️ BLOQUEADO! Encontrado status Pendente/Encaminhado.${SEM_COR}"

        # AÇÃO: Deve estar em hold
        if [ "$estado_hold" == "Sim" ]; then
            echo -e "   • Ação:              ${VERDE}Mantido em hold com sucesso (Sistema protegido).${SEM_COR}"
        else
            if [ "$MODO_EXECUÇÃO" = true ]; then
                echo -e "   • Ação:              ${VERMELHO}Aplicando HOLD urgente...${SEM_COR}"
                sudo apt-mark hold "$pacote"
            else
                echo -e "   • Ação Simulada:     [SIMULAÇÃO] Executaria: sudo apt-mark hold $pacote"
            fi
        fi

    elif [ -n "$linhas_resolvidas" ]; then
        echo -e "   • Status de Bugs:    ${VERDE}✅ Todos os bugs deste pacote constam como [Resolvido].${SEM_COR}"

        # Critério de liberação por tempo
        if [ "$diferenca_dias" -ge 5 ]; then
            if [ "$estado_hold" == "Sim" ]; then
                if [ "$MODO_EXECUÇÃO" = true ]; then
                    echo -e "   • Ação:              ${VERDE}Quarentena concluída. Executando UNHOLD...${SEM_COR}"
                    sudo apt-mark unhold "$pacote"
                else
                    echo -e "   • Ação Simulada:     [SIMULAÇÃO] Executaria: sudo apt-mark unhold $pacote"
                fi
            else
                echo -e "   • Ação:              Livre para atualizar normalmente."
            fi
        else
            dias_restantes=$(( 5 - diferenca_dias ))
            if [ "$estado_hold" == "Sim" ]; then
                echo -e "   • Ação:              ${AMARELO}Mantido em hold (Quarentena incompleta: faltam $dias_restantes dias).${SEM_COR}"
            else
                if [ "$MODO_EXECUÇÃO" = true ]; then
                    echo -e "   • Ação:              ${AMARELO}Bugs resolvidos recentemente. Colocando em HOLD preventivo temporal...${SEM_COR}"
                    sudo apt-mark hold "$pacote"
                else
                    echo -e "   • Ação Simulada:     [SIMULAÇÃO] Executaria hold preventivo por tempo: sudo apt-mark hold $pacote"
                fi
            fi
        fi
    else
        echo -e "   • Status de Bugs:    ${VERDE}✅ Nenhum bug listado no apt-listbugs.${SEM_COR}"

        if [ "$diferenca_dias" -ge 5 ]; then
            if [ "$estado_hold" == "Sim" ]; then
                if [ "$MODO_EXECUÇÃO" = true ]; then
                    echo -e "   • Ação:              ${VERDE}Livre de bugs e tempo expirado. Executando UNHOLD...${SEM_COR}"
                    sudo apt-mark unhold "$pacote"
                else
                    echo -e "   • Ação Simulada:     [SIMULAÇÃO] Executaria: sudo apt-mark unhold $pacote"
                fi
            else
                echo -e "   • Ação:              Livre para atualizar normalmente."
            fi
        else
            dias_restantes=$(( 5 - diferenca_dias ))
            if [ "$estado_hold" == "Sim" ]; then
                echo -e "   • Ação:              ${AMARELO}Mantido em hold (Aguardando quarentena de tempo, faltam $dias_restantes dias).${SEM_COR}"
            else
                if [ "$MODO_EXECUÇÃO" = true ]; then
                    echo -e "   • Ação:              ${AMARELO}Pacote limpo, mas em janela de risco. Aplicando HOLD temporal...${SEM_COR}"
                    sudo apt-mark hold "$pacote"
                else
                    echo -e "   • Ação Simulada:     [SIMULAÇÃO] Executaria hold de segurança: sudo apt-mark hold $pacote"
                fi
            fi
        fi
    fi
    echo "----------------------------------------------------------------------"
done
