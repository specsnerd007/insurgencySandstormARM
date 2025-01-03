# Base image
FROM ubuntu:20.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV BOX64_LOG=1  # Optional, for debugging box64
ENV STEAM_APP_ID=581330  # Insurgency: Sandstorm server app ID
ENV INSTALL_DIR=/steamcmd/sandstorm-server

# Update and install ARM64-compatible system dependencies
RUN apt update && apt install -y \
    curl wget software-properties-common gcc g++ \
    ca-certificates lib32stdc++6 unzip

# Install Box64 for x86 emulation on ARM64
RUN add-apt-repository ppa:ptitseb/box64 && \
    apt update && apt install -y box64

# Download and set up SteamCMD
RUN mkdir -p /steamcmd && \
    curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -xz -C /steamcmd

# Add steamcmd to PATH for convenience
ENV PATH="/steamcmd:$PATH"

# Create installation directory for Insurgency Sandstorm
RUN mkdir -p ${INSTALL_DIR}

# Add necessary user and permissions (optional)
RUN useradd -ms /bin/bash steam && \
    chown -R steam:steam /steamcmd ${INSTALL_DIR}
USER steam
WORKDIR /steamcmd

# Install Insurgency Sandstorm Dedicated Server using SteamCMD
RUN ./steamcmd.sh +login anonymous +app_update ${STEAM_APP_ID} validate +quit

# Expose the default server ports
EXPOSE 27102/udp 27131/udp

# Set the working directory to the server installation directory
WORKDIR ${INSTALL_DIR}

# Default command to start the Insurgency Sandstorm server
CMD ["./Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping", "Farmhouse?Scenario=Scenario_Farmhouse_Checkpoint_Security", "-Port=27102", "-QueryPort=27131"]
