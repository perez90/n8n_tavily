FROM n8nio/n8n:latest

USER root

# --- PASO 1: Instalar en una zona neutral ---
# Vamos a una carpeta temporal para que npm no detecte los "workspaces" de n8n
WORKDIR /tmp
# Instalamos el paquete aquí
RUN npm install @tavily/n8n-nodes-tavily

# --- PASO 2: Inyección Manual ---
# Creamos la carpeta de destino dentro de n8n
RUN mkdir -p /usr/local/lib/node_modules/n8n/node_modules/@tavily

# Copiamos lo que instalamos en /tmp directamente al corazón de n8n
# Esto evita el error de "workspace" y el error de "volumen oculto"
RUN cp -r /tmp/node_modules/@tavily/n8n-nodes-tavily /usr/local/lib/node_modules/n8n/node_modules/@tavily/

# --- PASO 3: Configuración Final ---
# Limpiamos la basura temporal
RUN rm -rf /tmp/node_modules

# Solución para el error rojo de "X-Forwarded-For"
ENV N8N_PROXY_HOPS=1

# Regresamos al usuario normal y a su carpeta
WORKDIR /home/node
USER node
