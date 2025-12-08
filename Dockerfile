# Usamos la última versión estable de n8n
FROM n8nio/n8n:latest

USER root

# 1. Instalar dependencias de compilación (necesarias para algunos nodos)
RUN apk add --update --no-cache python3 make g++

# 2. Crear una carpeta segura FUERA de /home/node/.n8n
# Usamos /opt/n8n-custom para que el volumen de datos no la oculte
WORKDIR /opt/n8n-custom

# 3. Iniciar un package.json e instalar Tavily
# Usamos 'n8n-nodes-tavily' que es el paquete estándar actual
RUN npm init -y && \
    npm install n8n-nodes-tavily --legacy-peer-deps --production

# 4. Configurar la variable de entorno para que n8n sepa dónde buscar el nodo
# Esto es CRUCIAL: le decimos a n8n que cargue el nodo desde esta ruta externa
ENV N8N_CUSTOM_EXTENSIONS=/opt/n8n-custom/node_modules/n8n-nodes-tavily

# 5. Permisos y volver al usuario node
RUN chown -R node:node /opt/n8n-custom
USER node

# Volver al directorio de trabajo original
WORKDIR /home/node

# El ENTRYPOINT original se mantiene
