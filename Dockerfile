# Dockerfile - n8n con Tavily (Actualizado y seguro para Volúmenes)
FROM n8nio/n8n:latest

USER root

# 1. Instalar herramientas de compilación básicas (por si el nodo las requiere al compilar)
# La imagen oficial está basada en Alpine, por lo que usamos apk
RUN apk add --update --no-cache python3 make g++

# 2. Crear una carpeta FUERA de ~/.n8n para instalar los nodos.
# Esto evita que se borren cuando Koyeb monte tu volumen de datos persistentes.
WORKDIR /opt/n8n/custom

# 3. Inicializar npm e instalar el nodo
# NOTA: El paquete público estándar es 'n8n-nodes-tavily'.
# Si tu paquete específico era '@tavily/n8n-nodes-tavily', cambia el nombre abajo.
RUN npm init -y && \
    npm install n8n-nodes-tavily --legacy-peer-deps --loglevel verbose

# 4. Configurar la variable de entorno para que n8n cargue el nodo desde aquí
# Apuntamos directamente a la carpeta del paquete instalado
ENV N8N_CUSTOM_EXTENSIONS=/opt/n8n/custom/node_modules/n8n-nodes-tavily

# Limpieza y permisos
USER node
WORKDIR /home/node

# El ENTRYPOINT original de n8n se mantiene intacto automáticamente
