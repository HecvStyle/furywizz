#!/bin/sh

if [[ -n $(docker ps -q -f "name=^hugo$") ]];then
        echo "正在运行Hugo..."
        cp site $HOME/blog/site
        cp Caddyfile $HOME/blog
        docker restart hugo
elif [[ -n $(docker ps -aq -f "name=^hugo$") ]];then
        echo "hugo 已经停止"
        docker rm -f hugo
        docker run --name hugo -p 80:80 -p 443:443 -d -v ${HOME}/blog//Caddyfile:/etc/caddy/Caddyfile -v ${HOME}/blog/site:/var/www  -v ${HOME}/blog/config:/config -v ${HOME}/blog/data:/data -e TZ=Asia/Shanghai caddy
else
        docker run --name hugo -p 80:80 -p 443:443 -d -v ${HOME}/blog//Caddyfile:/etc/caddy/Caddyfile -v ${HOME}/blog/site:/var/www  -v ${HOME}/blog/config:/config -v ${HOME}/blog/data:/data -e TZ=Asia/Shanghai caddy
fi
