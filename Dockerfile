FROM n8nio/n8n:latest

USER root

# Instalación global para evitar conflictos con volúmenes de usuario
RUN npm install -g n8n-nodes-tavily

USER node
