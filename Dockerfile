FROM n8nio/n8n:latest

USER root

# Instalamos TU paquete específico (@tavily/...) de forma global
# Esto evita el error de permisos y carpetas ocultas en Koyeb
RUN npm install -g @tavily/n8n-nodes-tavily

USER node
