FROM n8nio/n8n:latest

USER root

# 1. Instalar herramientas necesarias
RUN apk add --update --no-cache python3 make g++

# 2. Instalar el nodo en una carpeta de "Respaldo" (fuera de la zona de peligro)
WORKDIR /fallback_nodes
RUN npm init -y && \
    npm install n8n-nodes-tavily --legacy-peer-deps --production

# 3. Crear script de arranque inteligente
# Este script copiará el nodo a tu carpeta de datos cada vez que inicies
RUN echo '#!/bin/sh' > /docker-entrypoint-custom.sh && \
    echo 'echo "🔄 Iniciando carga de nodos personalizados..."' >> /docker-entrypoint-custom.sh && \
    echo 'mkdir -p /home/node/.n8n/custom/node_modules' >> /docker-entrypoint-custom.sh && \
    echo 'cp -r /fallback_nodes/node_modules/* /home/node/.n8n/custom/node_modules/' >> /docker-entrypoint-custom.sh && \
    echo 'chown -R node:node /home/node/.n8n/custom' >> /docker-entrypoint-custom.sh && \
    echo 'echo "✅ Nodos cargados. Iniciando n8n..."' >> /docker-entrypoint-custom.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh

USER node

# 4. Forzamos n8n a mirar en la carpeta estándar (por si acaso)
WORKDIR /home/node

# Usamos nuestro script como lanzador
ENTRYPOINT ["/docker-entrypoint-custom.sh"]
