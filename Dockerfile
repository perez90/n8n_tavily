# Dockerfile - n8n con Tavily para Koyeb (CORREGIDO)
FROM n8nio/n8n:latest

# Cambiar a root solo para crear directorios
USER root

# Crear directorio custom y ajustar permisos
RUN mkdir -p /home/node/.n8n/custom && \
    chown -R node:node /home/node/.n8n

# Volver a usuario node
USER node
WORKDIR /home/node/.n8n/custom

# Instalar Tavily
RUN npm init -y && \
    npm install @tavily/n8n-nodes-tavily --legacy-peer-deps --loglevel=verbose || \
    npm install @tavily/n8n-nodes-tavily --force --loglevel=verbose

# Verificar instalación
RUN echo "=== Verificando Tavily ===" && \
    ls -la node_modules/@tavily/ 2>/dev/null || echo "⚠️ Tavily no encontrado" && \
    cat package.json

# Variables de entorno
ENV N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/custom"
ENV NODE_FUNCTION_ALLOW_EXTERNAL="*"

WORKDIR /home/node

# NO tocar el ENTRYPOINT ni el CMD - usar el original de la imagen base
# La imagen n8n ya tiene configurado cómo ejecutarse
