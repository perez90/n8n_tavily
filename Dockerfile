FROM n8nio/n8n:latest

USER root

# 1. INSTALACIÓN EN EL SISTEMA (SEGURO Y CON TODAS LAS DEPENDENCIAS)
# Lo instalamos globalmente en /usr/local/lib...
RUN npm install -g @tavily/n8n-nodes-tavily

# 2. ARREGLO DEL ERROR "X-Forwarded-For" (Los mensajes rojos)
ENV N8N_PROXY_HOPS=1

# 3. SCRIPT DE ARRANQUE CON ENLACE SIMBÓLICO
# En lugar de copiar, creamos un acceso directo.
# Si el nodo Tavily requiere otras librerías, Node las encontrará en el sistema.
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo ">>> CREANDO ACCESO DIRECTO A TAVILY..."' >> /start.sh && \
    # Crear la carpeta de nodos en el volumen persistente de Koyeb
    echo 'mkdir -p /home/node/.n8n/nodes' >> /start.sh && \
    # Limpiamos enlaces viejos por si acaso
    echo 'rm -rf /home/node/.n8n/nodes/n8n-nodes-tavily' >> /start.sh && \
    # Creamos el enlace simbólico (Shortcut): Sistema -> Tu carpeta
    # OJO: Apuntamos directamente a la carpeta del paquete, quitando el scope @tavily para facilitar la lectura
    echo 'ln -s /usr/local/lib/node_modules/@tavily/n8n-nodes-tavily /home/node/.n8n/nodes/n8n-nodes-tavily' >> /start.sh && \
    # Aseguramos permisos correctos
    echo 'chown -R node:node /home/node/.n8n' >> /start.sh && \
    echo 'echo ">>> TAVILY ENLAZADO. ARRANCANDO N8N..."' >> /start.sh && \
    # Arrancamos n8n
    echo 'exec /docker-entrypoint.sh' >> /start.sh && \
    chmod +x /start.sh

# 4. EJECUCIÓN
USER node
ENTRYPOINT ["/start.sh"]
