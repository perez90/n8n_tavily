# Dockerfile - n8n con nodo Tavily
FROM n8nio/n8n:latest

# trabajar como root para crear carpetas
USER root
RUN mkdir -p /home/node/.n8n/custom && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node

# instala el paquete Tavily en la carpeta custom de n8n
# sustituye el nombre del paquete si fuera otro
RUN npm --silent --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily

USER node
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
