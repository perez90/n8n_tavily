FROM n8nio/n8n:latest

USER root

# 1. INSTALACIÓN LIMPIA EN ZONA TEMPORAL
# Usamos /tmp para que npm no se queje de permisos ni workspaces
WORKDIR /tmp
RUN npm install @tavily/n8n-nodes-tavily

# 2. TRASPLANTE AL NÚCLEO DE N8N
# Creamos la carpeta de destino dentro de las librerías oficiales de n8n
RUN mkdir -p /usr/local/lib/node_modules/n8n/node_modules/@tavily

# Movemos físicamente los archivos. 
# Al ponerlo aquí, n8n lo carga como si fuera un nodo nativo del sistema.
RUN cp -r node_modules/@tavily/n8n-nodes-tavily /usr/local/lib/node_modules/n8n/node_modules/@tavily/

# 3. LIMPIEZA Y PERMISOS (CRÍTICO)
# Borramos la basura temporal
RUN rm -rf /tmp/*
# Le regalamos la propiedad de los archivos al usuario node para que pueda leerlos
RUN chown -R node:node /usr/local/lib/node_modules/n8n/node_modules/@tavily

# 4. AJUSTES DE RED
# Esto evita los errores rojos de "X-Forwarded-For"
ENV N8N_PROXY_HOPS=1

# Volvemos al usuario estándar
WORKDIR /home/node
USER node
