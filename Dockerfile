FROM n8nio/n8n:latest

# trabajar como root para crear carpetas
USER root
RUN mkdir -p /home/node/.n8n/custom && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node

# instalar el paquete Tavily (si hay conflictos de dependencias usamos --legacy-peer-deps)
# y guardamos los artefactos en la carpeta custom que n8n lee al arrancar
RUN npm --silent --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --legacy-peer-deps || \
    (echo "npm install falló; intentando con --force" && npm --silent --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --force)

# Mostrar estructura para debug (aparecerá en los logs del build)
RUN echo "==== /home/node/.n8n/custom ====" && ls -la /home/node/.n8n/custom || true
RUN echo "==== /home/node/.n8n/custom/node_modules ====" && ls -la /home/node/.n8n/custom/node_modules || true
RUN echo "==== package.json (si existe) ====" && cat /home/node/.n8n/custom/package.json 2>/dev/null || echo "no package.json"

USER node
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
