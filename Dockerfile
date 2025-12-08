# Dockerfile - n8n con Tavily para Koyeb
# Usa la versión más reciente de n8n
FROM n8nio/n8n:latest

# Cambiar a root solo para crear directorios y ajustar permisos
USER root

# Crear directorio custom y asegurar permisos correctos
RUN mkdir -p /home/node/.n8n/custom && \
    chown -R node:node /home/node/.n8n

# Volver a usuario node para todas las operaciones npm
USER node

# Establecer directorio de trabajo
WORKDIR /home/node/.n8n/custom

# Instalar Tavily con manejo robusto de errores
RUN npm init -y && \
    npm install @tavily/n8n-nodes-tavily --legacy-peer-deps --loglevel=verbose || \
    npm install @tavily/n8n-nodes-tavily --force --loglevel=verbose

# Verificar instalación (debug)
RUN echo "=== Verificando instalación ===" && \
    ls -la /home/node/.n8n/custom/node_modules/@tavily/ 2>/dev/null || echo "⚠️  Tavily no encontrado en ubicación esperada" && \
    echo "=== Contenido de custom ===" && \
    ls -la /home/node/.n8n/custom && \
    echo "=== package.json ===" && \
    cat /home/node/.n8n/custom/package.json

# Variables de entorno para n8n
ENV N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/custom"
ENV NODE_FUNCTION_ALLOW_EXTERNAL="*"

# Volver a directorio home
WORKDIR /home/node

# Mantener el ENTRYPOINT original de n8n
# n8n moderno usa "docker-entrypoint.sh", no "tini"
CMD ["n8n"]
