FROM n8nio/n8n:latest

USER root
RUN mkdir -p /home/node/.n8n/custom && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node

# instalar el paquete Tavily sin --silent para ver errores y con legacy peer deps
RUN npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --legacy-peer-deps --loglevel verbose || \
    (echo "npm install falló; intentando con --force" && npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --force --loglevel verbose)

# intentar build si el paquete lo requiere (muchos paquetes TS requieren build)
RUN if [ -f /home/node/.n8n/custom/package.json ]; then \
      echo "package.json encontrado, intentando npm run build (si existe)"; \
      (cd /home/node/.n8n/custom && npm run build) || echo "no hay script build o falló"; \
    else \
      echo "no hay package.json en custom"; \
    fi

# Mostrar estructura para debug (aparecerá en los logs del build)
RUN echo "==== /home/node/.n8n/custom ====" && ls -la /home/node/.n8n/custom || true
RUN echo "==== /home/node/.n8n/custom/node_modules ====" && ls -la /home/node/.n8n/custom/node_modules || true
RUN echo "==== contenido relacionado con tavily ====" && ls -la /home/node/.n8n/custom/node_modules | grep tavily || true
RUN echo "==== package.json (si existe) ====" && cat /home/node/.n8n/custom/package.json 2>/dev/null || echo "no package.json"

USER node
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
