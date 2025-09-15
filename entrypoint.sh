#!/bin/bash
set -e

# Função para iniciar o servidor ARK
start_ark_server() {
    echo "Iniciando servidor ARK..."
    
    cd /ark/ShooterGame/Binaries/Linux/
    
    ./ShooterGameServer \
        "${SERVERMAP}?listen?SessionName=${SESSIONNAME}?ServerPassword=${SERVERPASSWORD}?ServerAdminPassword=${ADMINPASSWORD}?Port=${SERVER_PORT}?QueryPort=${QUERY_PORT}?RCONEnabled=True?RCONPort=${RCON_PORT}" \
        -server \
        -log \
        -UseBattlEye \
        -crossplay \
        -servergamelog &
}

# Função para iniciar o painel web
start_web_panel() {
    echo "Iniciando painel web na porta ${WEB_PORT}..."
    nginx -g "daemon off;" &
}

# Iniciar todos os serviços
start_web_panel
start_ark_server

# Manter o container rodando
echo "================================================"
echo "Servidor ARK está rodando!"
echo "Conecte-se ao jogo na porta: ${SERVER_PORT}"
echo "Painel web disponível na porta: ${WEB_PORT}"
echo "Senha de administrador: ${ADMINPASSWORD}"
echo "================================================"

# Aguardar indefinidamente
wait