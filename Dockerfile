FROM debian:8
# 1.1.0 is last version of docker with a tweak to save or load
RUN apt-get update && \
    apt-get install -yy python git wget make gcc linux-libc-dev python-dev && \
    wget --quiet -O docker https://get.docker.com/builds/Linux/x86_64/docker-1.1.0 && \
    chmod +x /docker && \
    git clone https://github.com/bup/bup.git && \
    cd /bup && \
    git checkout 0.27 && make && make install && \
    cd / && \
    rm -rf bup && \
    apt-get autoremove -yy --purge wget make gcc linux-libc-dev python2.7-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD []
