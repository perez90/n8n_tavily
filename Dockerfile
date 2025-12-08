# Dockerfile optimizado para Koyeb
FROM n8nio/n8n:latest

# Koyeb puede ejecutar como root, así que simplificamos
USER root

# Crear estructura de directorios con permisos adecuados
RUN mkdir -p /data/.n8n/custom && \
    mkdir -p /home/node/.n8n/custom && \
    chown -R node:node /data && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 755 /data && \
    chmod -R 755 /home/node/.n8n

# Cambiar a usuario node para npm
USER node
WORKDIR /home/node/.n8n/custom

# Instalar Tavily con múltiples intentos
RUN npm init -y --scope=custom && \
    (npm install @tavily/n8n-nodes-tavily --legacy-peer-deps || \
     npm install @tavily/n8n-nodes-tavily --force || \
     npm install @tavily/n8n-nodes-tavily) && \
    echo "✅ Tavily instalado correctamente"

# Verificación detallada
RUN echo "=== Verificación de instalación ===" && \
    test -d node_modules/@tavily && echo "✅ Directorio @tavily existe" || echo "❌ NO existe @tavily" && \
    test -f node_modules/@tavily/n8n-nodes-tavily/package.json && echo "✅ package.json de Tavily encontrado" || echo "❌ package.json NO encontrado" && \
    ls -la node_modules/@tavily/n8n-nodes-tavily/ 2>/dev/null | head -20 || echo "No se puede listar contenido" && \
    echo "=== Contenido de package.json local ===" && \
    cat package.json

# Variables de entorno necesarias
ENV N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/custom"
ENV NODE_FUNCTION_ALLOW_EXTERNAL="*"
ENV N8N_DIAGNOSTICS_ENABLED="false"

# Configuración para Koyeb (opcional pero recomendado)
ENV N8N_HOST="0.0.0.0"
ENV N8N_PORT="8080"
ENV N8N_PROTOCOL="https"
ENV WEBHOOK_URL="https://tu-app.koyeb.app/"

WORKDIR /home/node

# Puerto para Koyeb
EXPOSE 8080

# Comando de inicio
CMD ["n8n", "start"]
