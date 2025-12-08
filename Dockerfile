FROM n8nio/n8n:latest

USER root

# 1. SOLUCIÓN AL "NODO NO RECONOCIDO":
# En lugar de instalarlo global (-g), nos metemos en la carpeta donde está instalado n8n
# e instalamos Tavily como si fuera una dependencia nativa de n8n.
WORKDIR /usr/local/lib/node_modules/n8n
RUN npm install @tavily/n8n-nodes-tavily

# 2. SOLUCIÓN AL ERROR DE "X-Forwarded-For":
# Esto elimina el spam en los logs y arregla problemas de conexión en Koyeb.
ENV N8N_PROXY_HOPS=1

# Regresamos a la configuración normal de usuario
WORKDIR /home/node
USER node
