FROM ptakes/base:latest
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

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs

# update npm ('npm install -g npm' not working)
RUN mkdir -p /tmp/npmupgrade \
    && cd /tmp/npmupgrade \
    && npm install npm \
    && rm -rf /usr/local/lib/node_modules \
    && mv node_modules /usr/local/lib/ \
    && rm -rf /usr/lib/node_modules \
    && ln -s /usr/local/lib/node_modules /usr/lib/node_modules \
    && cd .. \
    && rm -rf npmupgrade

# install global npm packages
RUN npm install -g rimraf gulp-cli webpack typescript tslint typings ts-node

# install git
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git

# install mono (not needed for .NET Core, ASP.NET Core and EF Core)
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
#    && echo 'deb http://download.mono-project.com/repo/debian jessie main' >> /etc/apt/sources.list.d/mono-xamarin.list \
#    && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" >> /etc/apt/sources.list.d/mono-xamarin.list \
#    && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" >> /etc/apt/sources.list.d/mono-xamarin.list \
#    && apt-get update \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mono-complete

# install dotnet
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libunwind8 gettext \
    && curl -sSL -o /tmp/dotnet.tar.gz https://go.microsoft.com/fwlink/?linkid=847105 \
    && mkdir -p /usr/share/dotnet \ 
    && tar -zxf /tmp/dotnet.tar.gz -C /usr/share/dotnet \
    && rm /tmp/dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# warmup dotnet
#TODO warmup to /var/vsode and copy to $home at first run?

# install vscode
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
    && echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' >> /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libxss1 libgconf2-4 libasound2 code
    
# install vscode extensions
# TODO: C# TSLint ... to /var/vsode/extensions and copy to $home on first run?
    
# final update and cleanup
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
    && apt-get clean

# startup
USER $ARG_USER
WORKDIR $ARG_HOME
ENTRYPOINT sudo /var/docker/mountvolumes.sh && xpra start $DISPLAY --bind-tcp="0.0.0.0:$XPRA_PORT" && sleep infinity
