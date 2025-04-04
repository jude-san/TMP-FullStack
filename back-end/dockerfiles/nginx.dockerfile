FROM nginx:stable-alpine

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
RUN sed -i "s/user  nginx/user ${USER}/g" /etc/nginx/nginx.conf

# ENV NEXT_PUBLIC_API_URL=/api

COPY ./back-end/dockerfiles/nginx/default.conf /etc/nginx/conf.d/
# COPY ./back-end/public /var/www/html/public
# COPY ./front-end /var/www/frontend

# RUN mkdir -p /var/www/html
