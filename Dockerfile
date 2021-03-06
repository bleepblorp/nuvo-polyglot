FROM node:10-alpine

EXPOSE 3000

WORKDIR /opt/polyglot-v2/
RUN apk add --no-cache --virtual .build-deps linux-headers build-base && \
    apk add --no-cache python3 python3-dev py3-pip bash git ca-certificates wget tzdata openssl zip && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    rm -r /root/.cache && \
    cd /opt && \
    git clone --depth=1 --single-branch --branch master https://github.com/UniversalDevicesInc/polyglot-v2.git && \
    cd /opt/polyglot-v2 && \
    npm install && \
    apk del .build-deps

RUN addgroup -S polyglot && adduser -S -G polyglot polyglot

USER polyglot
WORKDIR /home/polyglot

RUN mkdir -p /home/polyglot/.polyglot/nodeservers/nuvo-polyglot/profile
COPY ./src/nuvo_polyglot/*.py .polyglot/nodeservers/nuvo-polyglot/
COPY ./polyglot/profile .polyglot/nodeservers/nuvo-polyglot/profile/
COPY ./polyglot/install.sh .polyglot/nodeservers/nuvo-polyglot/
COPY ./polyglot/server.json .polyglot/nodeservers/nuvo-polyglot/
COPY ./polyglot/dot-env.template .polyglot/.env

WORKDIR .polyglot/nodeservers/nuvo-polyglot/profile/
RUN zip -r ../profile.zip *
# Run Polyglot
WORKDIR /opt/polyglot-v2/
CMD npm start


