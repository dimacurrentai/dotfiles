#!/bin/bash
#
# This script is meant to be run right after `sudo adduser ...`.
#
# Friendly reminders:
# 1) Run `./dkorolev_setup_user.sh` for each newly created user.
# 2) The recommended way to create users is `sudo adduser --encrypt-home {DESIRED_USERNAME}`.

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

cat <<EOF >/tmp/.profile.$U
[User]
Session=
Icon=/var/lib/AccountsService/icons/$U
SystemAccount=false

[InputSource0]
xkb=us
EOF

sudo mv /tmp/.profile.$U /var/lib/AccountsService/users/$U
sudo chown root: /var/lib/AccountsService/users/$U

echo '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' \
  | base64 --decode >/tmp/.icon.$U
sudo mv /tmp/.icon.$U /var/lib/AccountsService/icons/$U
sudo chown $U: /var/lib/AccountsService/icons/$U
