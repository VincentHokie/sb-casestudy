FROM ubuntu:18.04
WORKDIR /app
RUN apt-get update && \
    apt-get install -y build-essential checkinstall && \
    apt-get install -y wget libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev && \
    wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz && \
    tar xzf Python-3.6.6.tgz && \
    cd Python-3.6.6 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    apt-get install -y nginx curl && \
    curl https://bootstrap.pypa.io/get-pip.py | python3.6 && \
    apt-get update && \
    rm -rf Python-3.6.6*
