FROM n8nio/n8n:latest

USER root

# --- PASO 1: Descargar Tavily en una "Caja Fuerte" temporal ---
# Lo instalamos en /cache para que el volumen de Koyeb no lo toque/borre
WORKDIR /cache
RUN npm install @tavily/n8n-nodes-tavily

# --- PASO 2: Arreglar el error de Proxy (X-Forwarded-For) ---
# Esto elimina los logs rojos de validación de Koyeb
ENV N8N_PROXY_HOPS=1

# --- PASO 3: Crear el Script de Inyección ---
# Creamos un archivo start.sh que se ejecutará al iniciar.
# Este script copia el nodo desde la "Caja Fuerte" (/cache) a la carpeta real (.n8n/nodes)
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo ">>> INICIANDO INYECCION DE TAVILY..."' >> /start.sh && \
    # Creamos la carpeta de nodos si no existe
    echo 'mkdir -p /home/node/.n8n/nodes' >> /start.sh && \
    # Copiamos el nodo (usamos -u para copiar solo si es nuevo/modificado)
    echo 'cp -ru /cache/node_modules/@tavily /home/node/.n8n/nodes/' >> /start.sh && \
    echo 'echo ">>> TAVILY INYECTADO CORRECTAMENTE"' >> /start.sh && \
    # Ejecutamos el arranque normal de n8n
    echo 'exec /docker-entrypoint.sh' >> /start.sh && \
    chmod +x /start.sh

# --- PASO 4: Configurar el arranque ---
USER node
# Le decimos a Docker que use nuestro script en lugar del normal
ENTRYPOINT ["/start.sh"]
