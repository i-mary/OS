FROM debian
ADD docker.list /etc/apt/sources.list.d/
RUN apt-get update && apt-get -y upgrade && apt -y install nginx && apt-get clean && \
    cd /var/www/ && rm -rf ./* && \
    mkdir -p i-mary.com/img && \
    chmod -R 754 /var/www/i-mary.com/ && \
    useradd Mary && groupadd Proshakova && usermod -aG Proshakova Mary && \
    chown -R Mary:Proshakova /var/www/i-mary.com/ && \
    sed -i 's/\/var\/www\/html/\/var\/www\/i-mary.com/g' /etc/nginx/sites-enabled/default && \
    sed -i 's/user www-data/user Mary/g' /etc/nginx/nginx.conf
ADD index.html /var/www/i-mary.com/
ADD img.jpg /var/www/i-mary.com/img/
CMD ["nginx", "-g", "daemon off;"]
