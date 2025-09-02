FROM n8nio/n8n:latest

USER root
RUN mkdir -p /home/node/.n8n/custom && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node

# instalar nodo Tavily
RUN npm --silent --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily

USER node
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
