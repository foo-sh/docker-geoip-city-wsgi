FROM docker.io/library/python:3.14.0-slim

COPY requirements.txt .

RUN set -eux ; \
    apt-get update ; \
    apt-get -y upgrade ; \
    apt-get -y install --no-install-recommends \
        git \
        ; \
    rm -rf /var/lib/apt/lists/* ; \
    pip3 install -r requirements.txt ; \
    rm -f requirements.txt

RUN set -eux ; \ 
    find / \! \( -path /proc -prune -o -path /sys -prune \) -perm /06000 -type f -exec chmod -v a-s {} \;

RUN set -eux ; \
    mkdir -m 0755 /var/empty ; \
    groupadd geoip ; \
    useradd -d /var/empty -s /sbin/nologin -g geoip geoip

RUN set -eux ; \
    git clone https://github.com/fedora-infra/geoip-city-wsgi.git ; \
    install -m 0644 geoip-city-wsgi/geoip-city.wsgi /usr/local/libexec ; \
    rm -rf geoip-city-wsgi

USER geoip

EXPOSE 8000/tcp

CMD ["/usr/local/bin/python3", "/usr/local/libexec/geoip-city.wsgi"]
