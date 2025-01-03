FROM ubuntu:20.04

# Install system dependencies
RUN dpkg --add-architecture i386 && apt update && apt install -y \
    curl wget software-properties-common lib32gcc-s1 lib32stdc++6 box64

# Download and install SteamCMD
RUN mkdir -p /steamcmd && cd /steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && rm steamcmd_linux.tar.gz

# Install Insurgency: Sandstorm Server via SteamCMD
WORKDIR /steamcmd
RUN box64 ./steamcmd.sh +login anonymous +force_install_dir /sandstorm_server +app_update 581330 validate +quit

# Expose required ports
EXPOSE 27102/udp 27131/udp

# Set working directory for the server
WORKDIR /sandstorm_server

# Run the server
ENTRYPOINT ["./InsurgencyServer.sh"]
