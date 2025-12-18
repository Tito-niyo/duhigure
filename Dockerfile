FROM node:24-bullseye-slim

WORKDIR /app

# install build deps for native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3 g++ make libsqlite3-dev ca-certificates && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# install production deps and ensure sqlite3 is built for the target
RUN npm ci --production && npm rebuild sqlite3 --build-from-source || true

COPY . .

# Ensure data directory exists for SQLite and adjust ownership
RUN mkdir -p /data && chown -R node:node /app /data || true

ENV PORT=3000
ENV DB_FILE=/data/family_members.db
EXPOSE 3000
USER node
CMD ["npm", "start"]