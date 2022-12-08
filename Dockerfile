FROM caddy

WORKDIR /usr/share/caddy

COPY /site .

RUN ls