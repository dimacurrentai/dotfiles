#!/bin/bash
#
# Must be run as root while the user is logged in so that their directory is not encrypted.

set -e

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

U=$1

if [ "$U" == "" ] ; then
  echo 'Need one argument: the username.'
  exit 1
fi

if [[ $UID == 0 || $EUID == 0 ]] ; then
  echo 'Please do not run as `root`.'
  exit 1
elif ! ( [ "$EUID" -eq 0 ] || SUDO_ASKPASS=/bin/false sudo -A /bin/true >/dev/null 2>&1) ; then
  echo 'Need `sudo`.'
  exit 1
fi

if ! sudo [ -d /home/$U ] ; then
  echo 'Need the user who has a home directory.'
  exit 1
fi

if sudo [ -f /home/$U/Access-Your-Private-Data.desktop ] ; then
  echo 'Need to log in as that user since their homedir is encrypted.'
  exit 1
fi

CHROME_DEFAULT_PROFILE_BASE_DIR="$(sudo "${SCRIPT_DIR}/chrome_default_profile_base_dir.sh" "$U")"

sudo mkdir -p "/var/userdata"

EXTRAS_DIR="$CHROME_DEFAULT_PROFILE_BASE_DIR/dkorolev_extras"
sudo rm -rf "$EXTRAS_DIR"
sudo mkdir -p "$EXTRAS_DIR"
sudo chown $U: "$EXTRAS_DIR"

ICON="$(sudo cat "/var/lib/AccountsService/users/$U" | grep '^Icon=' | sed "s/^Icon=//")"
echo "Has icon: $ICON"
if sudo [ -f "$ICON" ] ; then
  echo 'The icon file exists.'
  sudo cp "$ICON" "$EXTRAS_DIR/icon.png"
  sudo chown $U: "$EXTRAS_DIR/icon.png"
else
  echo 'The icon file does not exist.'
fi

WALL="$(sudo runuser -u $U -- gsettings get org.gnome.desktop.background picture-uri  | xargs echo | sed 's/^file:\/\///')"
echo "Has wallpaper: $WALL"
if sudo [ -f "$WALL" ] ; then
  echo 'The wallpaper file does exist.'
  sudo cp "$WALL" "$EXTRAS_DIR/wall.jpg"
  sudo chown $U: "$EXTRAS_DIR/wall.jpg"
else
  echo 'The wallpaper file does not exist.'
fi

TS=$(date +%s)

PROFILE_DST="/var/userdata/$U.tar.gz.des3"
if sudo [ -f "$PROFILE_DST" ] ; then
  echo 'Found the old saved profile! Moving it under an older name.'
  sudo mv "$PROFILE_DST" "$PROFILE_DST.$TS"
fi

sudo mkdir -p "/var/userdata/scripts/$U"
sudo chown $U: "/var/userdata/scripts/$U"
sudo rm -f "/var/userdata/scripts/$U/doit.sh"
sudo touch "/var/userdata/scripts/$U/doit.sh"
sudo chown $U: "/var/userdata/scripts/$U"
sudo chmod 777 "/var/userdata/scripts/$U/doit.sh"

cat <<EOF >"/var/userdata/scripts/$U/doit.sh"
#!/bin/bash
set -e
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; tar czf $U.tar.gz.$TS Default dkorolev_extras)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; chown $U: $U.tar.gz.$TS)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; chmod 600 $U.tar.gz.$TS)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; rm -f $U.tar.gz)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; mv $U.tar.gz.$TS $U.tar.gz)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; openssl des3 -pbkdf2 <$U.tar.gz >$U.tar.gz.des3)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; rm -f $U.tar.gz)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; chown $U: $U.tar.gz.des3)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; chmod 600 $U.tar.gz.des3)
(cd "$CHROME_DEFAULT_PROFILE_BASE_DIR"; mv $U.tar.gz.des3 /var/userdata/)
EOF

sudo chmod 700 "/var/userdata/scripts/$U/"
echo 'Running `/var/userdata/scripts/$U/doit.sh`, it will prompt for encryption password.'
sudo "/var/userdata/scripts/$U/doit.sh"
echo 'Done!'

sudo rm -rf "$EXTRAS_DIR"
