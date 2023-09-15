#!/bin/bash
cd /home/container

# Information output
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1
# Install necessary to run packages
echo "First launch will throw some errors. Ignore them"
if [[ $WINETRICKS_RUN =~ gecko ]]; then
        echo "Installing Gecko"
        WINETRICKS_RUN=${WINETRICKS_RUN/gecko}

        if [ ! -f "$WINEPREFIX/gecko_x86.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86.msi
        fi

        if [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86_64.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86_64.msi
        fi

        wine msiexec /i $WINEPREFIX/gecko_x86.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_install.log
        wine msiexec /i $WINEPREFIX/gecko_x86_64.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_64_install.log
fi

# Check if wine-mono required and install it if so
if [[ $WINETRICKS_RUN =~ mono ]]; then
        echo "Installing mono"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/8.0.0/wine-mono-8.0.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
fi

# List and install other packages
for trick in $WINETRICKS_RUN; do
        echo "Installing $trick"
        winetricks -q $trick
done
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1
# Install necessary to run packages
echo "First launch will throw some errors. Ignore them"
mkdir -p $WINEPREFIX
cd empyrion
mkdir Logs



MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
[ "$1" = "bash" ] && exec "$@"
sh -c 'until [ "`netstat -ntl | tail -n+3`" ]; do sleep 1; done
sleep 5 # gotta wait for it to open a logfile
tail -F Logs/current.log ../Logs/*/*.log 2>/dev/null' &
eval ${MODIFIED_STARTUP}
# Replace Startup Variables


# Run the Server
