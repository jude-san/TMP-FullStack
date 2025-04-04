FROM composer:2

ARG UID=1000
ARG GID=1000 
ARG USER=laravelUser

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system ${USER}
RUN adduser -G ${USER} --system -D -s /bin/sh -u ${UID} ${USER}

WORKDIR /var/www/html

ENTRYPOINT [ "composer", "--ignore-platform-reqs" ]
