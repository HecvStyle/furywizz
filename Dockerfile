FROM caddy:2.6.2-alpine

WORKDIR /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY public .