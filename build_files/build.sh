#!/bin/bash

set -ouex pipefail

### Install packages

# Needs to be done fo make programs that uses opt to install correctry
rm /opt
mkdir -p /opt
# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

### Used for installing brave
dnf5 install -y dnf-plugins-core
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-browser

### is used to make 1password work on brave
mkdir -p /usr/lib/brave-browser/NativeMessagingHosts
cat > /usr/lib/brave-browser/NativeMessagingHosts/com.1password.1password.json << 'EOF'
{
  "name": "com.1password.1password",
  "description": "1Password desktop integration",
  "path": "/opt/1Password/1Password-BrowserSupport",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/"]
}
EOF

# 1password
rpm --import https://downloads.1password.com/linux/keys/1password.asc
sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'

dnf5 install -y 1password

### Configuring 1password to work correctry
groupmod -g 6001 onepassword
chgrp onepassword /opt/1Password/1Password-BrowserSupport
chmod g+s /opt/1Password/1Password-BrowserSupport
install -Dm0644 /opt/1Password/resources/custom_allowed_browsers -t /etc/1password/

# Native messaging manifest för Firefox
mkdir -p /usr/lib/mozilla/native-messaging-hosts
cat > /usr/lib/mozilla/native-messaging-hosts/com.1password.1password.json << 'EOF'
{
  "name": "com.1password.1password",
  "description": "1Password desktop integration",
  "path": "/opt/1Password/1Password-BrowserSupport",
  "type": "stdio",
  "allowed_extensions": [
    "{d634138d-c276-4fc8-924b-40a0ea21d284}",
    "d634138d-c276-4fc8-924b-40a0ea21d284",
    "support@1password.com"
  ]
}
EOF


dnf5 install -y sl
dnf5 install -y nvim
dnf5 install -y firefox
dnf5 install -y earlyoom

### MullvadVPN
dnf5 config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 install -y mullvad-vpn
dnf5 install -y mat2

systemctl enable podman.socket
