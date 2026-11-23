FROM alpine:3.21
RUN apk add --no-cache mariadb mariadb-client iproute2 \
    && sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf
