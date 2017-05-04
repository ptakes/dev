FROM debian:jessie
ARG ARG_LANG
ARG ARG_LANGUAGE
ARG ARG_TIMEZONE
ARG ARG_DISPLAY
ARG ARG_USER
ARG ARG_USER_NAME
ARG ARG_UID
ARG ARG_HOME
ARG ARG_GROUP
ARG ARG_GID
ARG ARG_XPRA_PORT
ARG ARG_DOCKER
ARG ARG_VOLUMES

USER root
WORKDIR /

# update debian
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-transport-https apt-utils unzip curl wget sudo vim-tiny ca-certificates openssl 

# set timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
    && ln -fs /usr/share/zoneinfo/$ARG_TIMEZONE /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# set locale
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales \
    && sed -i -e "s/# ${ARG_LANG}.UTF-8 UTF-8/${ARG_LANG}.UTF-8 UTF-8/" /etc/locale.gen \
    && echo "LANG=\"${ARG_LANG}.UTF-8\"" >/etc/default/locale && \
    dpkg-reconfigure -f noninteractive locales && \
    update-locale LANG=${ARG_LANG}.UTF-8

# install xpra & lilyterm
RUN curl http://winswitch.org/gpg.asc | apt-key add - \
    && echo "deb http://winswitch.org/ jessie main" >/etc/apt/sources.list.d/winswitch.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends xpra lilyterm

# create user   
RUN groupadd -r $ARG_GROUP -g $ARG_GID \
    && useradd -u $ARG_UID -r -g $ARG_GROUP -d $ARG_HOME -s /bin/bash -c "$ARG_USER_NAME" $ARG_USER \
    && passwd -d $ARG_USER \
    && echo "$ARG_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$ARG_USER \
    && mkdir -p $ARG_HOME \
    && chown -R $ARG_USER:$ARG_GROUP $ARG_HOME

# setup docker volume support
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends bindfs \
    && mkdir -p $ARG_DOCKER \
    && mkdir -p $ARG_VOLUMES
COPY mountvolumes.sh $ARG_DOCKER
RUN chmod 755 $ARG_DOCKER/mountvolumes.sh 

# set environment variables
ENV DISPLAY=$ARG_DISPLAY \
    LANG=${ARG_LANG}.UTF-8 \
    LANGUAGE=$ARG_LANGUAGE \
    SHELL=/bin/bash \
    XPRA_PORT=$ARG_XPRA_PORT

# final update and cleanup
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
    && apt-get clean

# startup
USER $ARG_USER
WORKDIR $ARG_HOME
ENTRYPOINT sudo /var/docker/mountvolumes.sh && xpra start $DISPLAY --bind-tcp="0.0.0.0:$XPRA_PORT" && sleep infinity

