FROM n8nio/n8n:latest

USER root

# 1. Instalar herramientas necesarias
RUN apk add --update --no-cache python3 make g++

# 2. Instalar el nodo en una carpeta temporal
# IMPORTANTE: Aquí instalamos la versión ESPECÍFICA que pide tu workflow (@tavily/...)
WORKDIR /fallback_nodes
RUN npm init -y && \
    npm install @tavily/n8n-nodes-tavily --legacy-peer-deps --production

# 3. Script de arranque "Nuclear"
# Este script fuerza la copia de los nodos a la carpeta de datos cada vez que arranca
RUN echo '#!/bin/sh' > /docker-entrypoint-custom.sh && \
    echo 'echo "🔄 Restaulando nodo Tavily específico..."' >> /docker-entrypoint-custom.sh && \
    echo 'mkdir -p /home/node/.n8n/custom/node_modules' >> /docker-entrypoint-custom.sh && \
    # Copiamos todo lo que haya en node_modules (incluyendo la carpeta @tavily)
    echo 'cp -r /fallback_nodes/node_modules/* /home/node/.n8n/custom/node_modules/' >> /docker-entrypoint-custom.sh && \
    echo 'chown -R node:node /home/node/.n8n/custom' >> /docker-entrypoint-custom.sh && \
    echo 'echo "✅ Nodos copiados. Iniciando n8n..."' >> /docker-entrypoint-custom.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh

USER node

WORKDIR /home/node

# Usamos el script personalizado
ENTRYPOINT ["/docker-entrypoint-custom.sh"]
