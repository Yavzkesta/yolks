# ---------------------------------------
# Generic Wine image based on Wine staging 
# ---------------------------------------
FROM            ubuntu:focal

LABEL           author="Michael Parker" maintainer="parker@pterodactyl.io"
LABEL           org.opencontainers.image.licenses=MIT
RUN             dpkg --add-architecture i386
RUN             apt-get update
RUN             apt-get install -y net-tools tar unzip curl xz-utils gnupg2 software-properties-common xvfb libc6:i386 locales wget netcat telnet
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
RUN             apt-get update
RUN             apt-get install -y wine-staging=8.9~focal-1 wine-staging-i386=8.9~focal-1 wine-staging-amd64=8.9~focal-1 winetricks cabextract 
## install required packages

# Set up Winetricks
RUN             mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine

COPY            ./../entrypoint.sh /entrypoint.sh
CMD             [ "/bin/bash", "/entrypoint.sh" ]