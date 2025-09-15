# Use a imagem base do SteamCMD
FROM cm2network/steamcmd:latest

# Defina variáveis de ambiente
ENV SERVERMAP="TheIsland" \
    SESSIONNAME="ARK Server" \
    SERVERPASSWORD="nether123" \
    ADMINPASSWORD="admin123" \
    MAX_PLAYERS=70 \
    SERVER_PORT=7777 \
    RCON_PORT=32330 \
    QUERY_PORT=27015 \
    WEB_PORT=8080 \
    SERVER_IP="0.0.0.0" \
    UPDATE_ON_START="true" \
    BACKUP_ON_STOP="false" \
    PRE_UPDATE_BACKUP="false" \
    WARN_ON_STOP="true"

# Instale dependências necessárias
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    lib32gcc1 \
    lib32stdc++6 \
    ca-certificates \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Crie diretórios necessários
RUN mkdir -p /ark /ark-backup /home/steam/.ark /opt/panel

# Instale o ARK Server
USER steam
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous \
    +force_install_dir /ark \
    +app_update 376030 validate \
    +quit

# Instale e configure o painel web
USER root
RUN cd /opt && \
    wget https://github.com/ark-server/ark-server-dashboard/archive/refs/heads/main.zip -O panel.zip && \
    unzip panel.zip && \
    mv ark-server-dashboard-main/* /opt/panel/ && \
    rm -rf panel.zip ark-server-dashboard-main

# Configure o Nginx para servir o painel na porta 8080
RUN echo 'server { \n\
    listen 8080; \n\
    server_name localhost; \n\
    root /opt/panel; \n\
    index index.html; \n\
    location / { \n\
        try_files \$uri \$uri/ /index.html; \n\
    } \n\
}' > /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Configure permissões
RUN chown -R steam:steam /ark /ark-backup /home/steam /opt/panel

# Exponha as portas necessárias
EXPOSE 7777/udp 7778/udp 27015/udp 32330 8080

# Copie script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

## VOLUME removido para compatibilidade com Railway (persistência não suportada)

# Defina o ponto de entrada
ENTRYPOINT ["/entrypoint.sh"]