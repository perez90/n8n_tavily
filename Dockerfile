# Dockerfile - n8n con el nodo Tavily (actualizado para versiones recientes)
FROM n8nio/n8n:latest

# Crear carpeta custom con permisos correctos
USER root
RUN mkdir -p /home/node/.n8n/custom && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 755 /home/node/.n8n

# Instalar dependencias del sistema si son necesarias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /home/node

# Configurar npm para evitar problemas de permisos
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Instalar el nodo Tavily con flags específicos para compatibilidad
RUN echo "Instalando nodo Tavily..." && \
    npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily@latest \
    --no-audit \
    --loglevel=info || \
    (echo "Primer intento falló, intentando con flags adicionales..." && \
     npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily@latest \
     --no-audit \
     --legacy-peer-deps \
     --loglevel=verbose)

# Verificar la instalación
RUN echo "=== Verificando instalación ===" && \
    echo "Contenido de custom:" && \
    ls -la /home/node/.n8n/custom/ 2>/dev/null || echo "No se pudo listar" && \
    echo -e "\nContenido de node_modules:" && \
    ls -la /home/node/.n8n/custom/node_modules/ 2>/dev/null || echo "No se pudo listar" && \
    echo -e "\nBuscando Tavily:" && \
    find /home/node/.n8n/custom -name "*tavily*" -type f 2>/dev/null || echo "No se encontraron archivos de Tavily"

# Configurar variables de entorno para n8n
ENV N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/custom"
ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV NODE_ENV="production"
ENV N8N_ENCRYPTION_KEY=""

# Puerto por defecto
EXPOSE 5678

# Mantener el entrypoint original
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
