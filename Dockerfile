FROM n8nio/n8n:2.9.1
USER root

# 1. Instalar herramientas necesarias (ahora es Debian, no Alpine)
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# 2. Instalar el nodo en una carpeta temporal
WORKDIR /fallback_nodes
RUN npm init -y && \
    npm install @tavily/n8n-nodes-tavily --legacy-peer-deps --production

# 3. Script de arranque
RUN echo '#!/bin/sh' > /docker-entrypoint-custom.sh && \
    echo 'echo "🔄 Restaurando nodo Tavily específico..."' >> /docker-entrypoint-custom.sh && \
    echo 'mkdir -p /home/node/.n8n/custom/node_modules' >> /docker-entrypoint-custom.sh && \
    echo 'cp -r /fallback_nodes/node_modules/* /home/node/.n8n/custom/node_modules/' >> /docker-entrypoint-custom.sh && \
    echo 'chown -R node:node /home/node/.n8n/custom' >> /docker-entrypoint-custom.sh && \
    echo 'echo "✅ Nodos copiados. Iniciando n8n..."' >> /docker-entrypoint-custom.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh

USER node
WORKDIR /home/node
ENTRYPOINT ["/docker-entrypoint-custom.sh"]
