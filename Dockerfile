# Dockerfile - n8n con el nodo Tavily (debug-friendly)
FROM n8nio/n8n:latest

# crear carpeta custom con permisos correctos
USER root
RUN mkdir -p /home/node/.n8n/custom && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node

# instalar el paquete Tavily mostrando logs no silenciosos
# usamos --legacy-peer-deps y --unsafe-perm por si hay problemas de dependencias/permiso
RUN npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --legacy-peer-deps --unsafe-perm --loglevel verbose || \
    (echo "npm install falló; intentando con --force" && npm --prefix /home/node/.n8n/custom install @tavily/n8n-nodes-tavily --force --unsafe-perm --loglevel verbose)

# intentar build si el paquete lo requiere (muchos paquetes TS necesitan build)
RUN if [ -f /home/node/.n8n/custom/package.json ]; then \
      echo "package.json encontrado en custom, intentando npm run build (si existe)"; \
      (cd /home/node/.n8n/custom && npm run build) || echo "no hay script build o build falló"; \
    else \
      echo "no hay package.json en custom"; \
    fi

# mostrar estructura para debug (aparecerá en los logs del build)
RUN echo "==== /home/node/.n8n/custom ====" && ls -la /home/node/.n8n/custom || true
RUN echo "==== /home/node/.n8n/custom/node_modules ====" && ls -la /home/node/.n8n/custom/node_modules || true
RUN echo "==== buscar tavily ====" && ls -la /home/node/.n8n/custom/node_modules 2>/dev/null | grep tavily || echo "no aparece tavily"
RUN echo "==== package.json (si existe) ====" && cat /home/node/.n8n/custom/package.json 2>/dev/null || echo "no package.json"

USER node

# mantener ENTRYPOINT original (n8n). No lo tocamos.
ENTRYPOINT ["tini", "--", "node", "/usr/local/bin/n8n"]
